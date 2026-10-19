import 'dart:async';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/haptic_feedback_helper.dart';
import '../models/draw_stroke_model.dart';
import '../services/realtime_database_service.dart';

class DrawingProvider with ChangeNotifier {
  final RealtimeDatabaseService _rtdb;
  static const _uuid = Uuid();

  String? _roomId;
  bool _isDrawer = false;
  Color _selectedColor = AppColors.drawingPalette.first;
  double _strokeWidth = 4.0;
  bool _isEraser = false;

  // Active in-progress stroke points
  final List<DrawPoint> _activePoints = [];
  String? _activeStrokeId;

  // Real-time strokes from Firebase
  List<DrawStroke> _strokes = [];
  StreamSubscription<List<DrawStroke>>? _strokesSubscription;

  DrawingProvider(this._rtdb);

  Color get selectedColor => _selectedColor;
  double get strokeWidth => _strokeWidth;
  bool get isEraser => _isEraser;
  List<DrawPoint> get activePoints => List.unmodifiable(_activePoints);
  List<DrawStroke> get strokes => List.unmodifiable(_strokes);
  bool get isDrawer => _isDrawer;

  /// Initialize drawing session for a room
  void initRoom({required String roomId, required bool isDrawer}) {
    if (_roomId == roomId && _isDrawer == isDrawer) return;

    _roomId = roomId;
    _isDrawer = isDrawer;
    _activePoints.clear();
    _activeStrokeId = null;

    _strokesSubscription?.cancel();
    _strokesSubscription = _rtdb.streamStrokes(roomId).listen((newStrokes) {
      _strokes = newStrokes;
      notifyListeners();
    });
  }

  void setColor(Color color) {
    _selectedColor = color;
    _isEraser = false;
    HapticHelper.selection();
    notifyListeners();
  }

  void setStrokeWidth(double width) {
    _strokeWidth = width;
    HapticHelper.selection();
    notifyListeners();
  }

  void toggleEraser() {
    _isEraser = !_isEraser;
    HapticHelper.selection();
    notifyListeners();
  }

  /// Finger touched canvas (Drawer only)
  void onPanStart(Offset localPosition, Size canvasSize, String drawerId) {
    if (!_isDrawer || _roomId == null || canvasSize.width <= 0 || canvasSize.height <= 0) return;

    final normX = (localPosition.dx / canvasSize.width).clamp(0.0, 1.0);
    final normY = (localPosition.dy / canvasSize.height).clamp(0.0, 1.0);

    _activeStrokeId = _uuid.v4();
    _activePoints.clear();
    _activePoints.add(DrawPoint(normX, normY));
    HapticHelper.light();
    notifyListeners();
  }

  /// Finger moved on canvas (Drawer only)
  void onPanUpdate(Offset localPosition, Size canvasSize) {
    if (!_isDrawer || _roomId == null || canvasSize.width <= 0 || canvasSize.height <= 0) return;

    final normX = (localPosition.dx / canvasSize.width).clamp(0.0, 1.0);
    final normY = (localPosition.dy / canvasSize.height).clamp(0.0, 1.0);

    // Filter points that are too close to minimize unnecessary overhead
    if (_activePoints.isNotEmpty) {
      final last = _activePoints.last;
      final dx = normX - last.x;
      final dy = normY - last.y;
      if ((dx * dx + dy * dy) < 0.00002) return; // ~3-4px threshold
    }

    _activePoints.add(DrawPoint(normX, normY));
    notifyListeners();
  }

  /// Finger lifted from canvas (Drawer only)
  Future<void> onPanEnd(String drawerId) async {
    if (!_isDrawer || _roomId == null || _activePoints.isEmpty || _activeStrokeId == null) {
      _activePoints.clear();
      _activeStrokeId = null;
      return;
    }

    final newStroke = DrawStroke(
      id: _activeStrokeId!,
      points: List.from(_activePoints),
      colorValue: _selectedColor.toARGB32(),
      strokeWidth: _strokeWidth,
      isEraser: _isEraser,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      order: _strokes.length,
      drawerId: drawerId,
    );

    _activePoints.clear();
    _activeStrokeId = null;

    // Push finalized stroke to Firebase RTDB
    await _rtdb.addStroke(_roomId!, newStroke);
  }

  /// Undo the last stroke
  Future<void> undo(String drawerId) async {
    if (!_isDrawer || _roomId == null || _strokes.isEmpty) return;
    final drawerStrokes = _strokes.where((s) => s.drawerId == drawerId).toList();
    if (drawerStrokes.isNotEmpty) {
      final lastStroke = drawerStrokes.last;
      HapticHelper.selection();
      await _rtdb.removeStroke(_roomId!, lastStroke.id);
    }
  }

  /// Clear entire canvas
  Future<void> clearCanvas() async {
    if (!_isDrawer || _roomId == null) return;
    HapticHelper.medium();
    await _rtdb.clearStrokes(_roomId!);
  }

  /// Reset provider state
  void reset() {
    _strokesSubscription?.cancel();
    _roomId = null;
    _isDrawer = false;
    _activePoints.clear();
    _strokes = [];
    notifyListeners();
  }

  @override
  void dispose() {
    _strokesSubscription?.cancel();
    super.dispose();
  }
}


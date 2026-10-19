import 'package:flutter/material.dart';

class DrawPoint {
  final double x; // Normalized 0.0 - 1.0
  final double y; // Normalized 0.0 - 1.0

  const DrawPoint(this.x, this.y);

  Map<String, dynamic> toMap() => {'x': x, 'y': y};

  factory DrawPoint.fromMap(Map<dynamic, dynamic> map) {
    return DrawPoint(
      (map['x'] as num).toDouble(),
      (map['y'] as num).toDouble(),
    );
  }
}

class DrawStroke {
  final String id;
  final List<DrawPoint> points;
  final int colorValue;
  final double strokeWidth;
  final bool isEraser;
  final int timestamp;
  final int order;
  final String? drawerId;

  const DrawStroke({
    required this.id,
    required this.points,
    required this.colorValue,
    required this.strokeWidth,
    this.isEraser = false,
    required this.timestamp,
    this.order = 0,
    this.drawerId,
  });

  Color get color => isEraser ? Colors.transparent : Color(colorValue);

  DrawStroke copyWith({
    String? id,
    List<DrawPoint>? points,
    int? colorValue,
    double? strokeWidth,
    bool? isEraser,
    int? timestamp,
    int? order,
    String? drawerId,
  }) {
    return DrawStroke(
      id: id ?? this.id,
      points: points ?? this.points,
      colorValue: colorValue ?? this.colorValue,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      isEraser: isEraser ?? this.isEraser,
      timestamp: timestamp ?? this.timestamp,
      order: order ?? this.order,
      drawerId: drawerId ?? this.drawerId,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'points': points.map((p) => p.toMap()).toList(),
      'colorValue': colorValue,
      'strokeWidth': strokeWidth,
      'isEraser': isEraser,
      'timestamp': timestamp,
      'order': order,
      'drawerId': drawerId,
    };
  }

  factory DrawStroke.fromMap(Map<dynamic, dynamic> map, String id) {
    final rawPoints = map['points'];
    final pointsList = <DrawPoint>[];

    if (rawPoints is List) {
      for (var p in rawPoints) {
        if (p is Map) {
          pointsList.add(DrawPoint.fromMap(p));
        }
      }
    }

    return DrawStroke(
      id: id,
      points: pointsList,
      colorValue: (map['colorValue'] as num?)?.toInt() ?? 0xFFFFFFFF,
      strokeWidth: (map['strokeWidth'] as num?)?.toDouble() ?? 4.0,
      isEraser: (map['isEraser'] as bool?) ?? false,
      timestamp: (map['timestamp'] as num?)?.toInt() ?? 0,
      order: (map['order'] as num?)?.toInt() ?? 0,
      drawerId: map['drawerId'] as String?,
    );
  }
}


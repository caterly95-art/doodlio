const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();
const rtdb = admin.database();
const firestore = admin.firestore();

/**
 * Normalizes text for comparison
 */
function normalize(text) {
  return (text || "")
    .trim()
    .toLowerCase()
    .replace(/[^\w\s]/g, "")
    .replace(/\s+/g, " ");
}

/**
 * Callable Function: Submit Guess securely to server
 * Validates against server-stored secret word and awards authoritative points
 */
exports.submitGuess = functions.https.onCall(async (data, context) => {
  // Check auth
  if (!context.auth) {
    throw new functions.https.HttpsError(
      "unauthenticated",
      "Player must be authenticated."
    );
  }

  const uid = context.auth.uid;
  const { roomId, guess } = data;

  if (!roomId || !guess) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "Missing roomId or guess."
    );
  }

  const roomSnap = await rtdb.ref(`rooms/${roomId}`).once("value");
  if (!roomSnap.exists()) {
    throw new functions.https.HttpsError("not-found", "Room not found.");
  }

  const room = roomSnap.val();

  // Validate state
  if (room.status !== "drawing") {
    return { status: "not_drawing" };
  }

  if (room.currentDrawerId === uid) {
    return { status: "drawer_cannot_guess" };
  }

  const player = room.players && room.players[uid];
  if (!player || player.hasGuessed) {
    return { status: "already_guessed" };
  }

  // Read secret word from secure path
  const secretSnap = await rtdb.ref(`secret_words/${roomId}/word`).once("value");
  const secretWord = secretSnap.val();

  if (!secretWord) {
    return { status: "no_secret_word" };
  }

  const isCorrect = normalize(guess) === normalize(secretWord);

  if (isCorrect) {
    const now = Date.now();
    const roundEndTime = room.roundEndTime || now + 1000;
    const duration = (room.config && room.config.drawDuration) || 60;
    const remainingMs = Math.max(0, roundEndTime - now);
    const fraction = remainingMs / (duration * 1000);

    const minPoints = 100;
    const maxPoints = 500;
    const points = Math.round(minPoints + fraction * (maxPoints - minPoints));

    // Update guesser
    const newGuesserScore = (player.score || 0) + points;
    await rtdb.ref(`rooms/${roomId}/players/${uid}`).update({
      hasGuessed: true,
      score: newGuesserScore,
      roundScore: points,
      guessedAt: now,
    });

    // Update drawer bonus
    if (room.currentDrawerId) {
      const drawerRef = rtdb.ref(`rooms/${roomId}/players/${room.currentDrawerId}`);
      const drawerSnap = await drawerRef.once("value");
      if (drawerSnap.exists()) {
        const d = drawerSnap.val();
        await drawerRef.update({
          score: (d.score || 0) + 75,
          roundScore: (d.roundScore || 0) + 75,
        });
      }
    }

    // Push system announcement to chat
    await rtdb.ref(`rooms/${roomId}/chat`).push({
      id: "sys_" + now,
      senderId: uid,
      senderName: player.displayName || "Player",
      text: `${player.displayName || "Player"} guessed the word! (+${points} pts)`,
      isSystem: true,
      isCorrectGuess: true,
      timestamp: now,
    });

    return { status: "correct", points: points };
  }

  return { status: "incorrect" };
});

/**
 * Scheduled Cloud Function: Clean up abandoned or expired rooms (> 2 hours old)
 */
exports.cleanupOldRooms = functions.pubsub
  .schedule("every 2 hours")
  .onRun(async (context) => {
    const twoHoursAgo = Date.now() - 2 * 60 * 60 * 1000;
    const roomsSnap = await rtdb.ref("rooms").once("value");

    if (!roomsSnap.exists()) return null;

    const updates = {};
    const secretsUpdates = {};

    roomsSnap.forEach((child) => {
      const room = child.val();
      if (room.createdAt && room.createdAt < twoHoursAgo) {
        updates[`rooms/${child.key}`] = null;
        secretsUpdates[`secret_words/${child.key}`] = null;
      }
    });

    await rtdb.ref().update({ ...updates, ...secretsUpdates });
    console.log("Cleaned up expired rooms successfully.");
    return null;
  });


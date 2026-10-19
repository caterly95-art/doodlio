# Doodlio — Online Multiplayer Drawing & Guessing Game

Doodlio is a production-oriented, real-time multiplayer drawing and word-guessing party game built with **Flutter**, **Firebase Authentication**, **Firebase Realtime Database**, **Cloud Firestore**, and **Firebase Cloud Functions**.

---

## 1. Visual Design & Theme System

Doodlio is crafted around a **minimal dark gaming interface**:

- **Background:** Near-black (`#0B0C10`)
- **Surface / Cards:** Dark charcoal (`#17191F` & elevated `#1E2129`)
- **Primary Accent:** Vivid Orange (`#FF7A30`)
- **Secondary Accent:** Soft White (`#F5F5F7`)
- **Borders & Dividers:** Subtle graphite (`#252932`)
- **Functional Semantics:**
  - Emerald Green (`#10B981`) for correct guesses & ready states
  - Amber Yellow (`#F59E0B`) for countdown warnings & hints
  - Crimson Red (`#EF4444`) for timer alert & errors
  - Royal Violet / Cyan / Lime curated drawing palette

---

## 2. Architecture & Directory Layout

```
lib/
├── app.dart                                # MaterialApp, Dark Theme definition
├── firebase_options.dart                   # Firebase Platform options (project borrow-e7211)
├── main.dart                               # Initialization, Services & MultiProvider setup
├── core/
│   ├── constants/
│   │   ├── app_colors.dart                 # Color palette & themes
│   │   ├── app_theme.dart                  # Material3 Dark Theme
│   │   └── game_constants.dart             # Rules, timings, scoring constants, limits
│   └── utils/
│       ├── haptic_feedback_helper.dart      # Tactile haptic feedback triggers
│       ├── sound_effects.dart              # Audio triggers with mute controls
│       └── word_repository.dart            # Categorized words, hints & spoiler protection
├── models/
│   ├── chat_message_model.dart             # Real-time chat & guess models
│   ├── draw_stroke_model.dart              # Normalized points & stroke serialization
│   ├── player_model.dart                   # Real-time multiplayer player states
│   ├── room_model.dart                     # Room config & lifecycle state
│   ├── round_result_model.dart             # Round summary data
│   └── user_profile_model.dart             # User profile, statistics & win rates
├── providers/
│   ├── auth_provider.dart                  # Guest & Email authentication & profile state
│   ├── drawing_provider.dart               # Live canvas, brushes, eraser, undo & RTDB sync
│   ├── game_provider.dart                  # Active match coordinator, game loop & timers
│   ├── leaderboard_provider.dart           # Global high-scores state
│   └── settings_provider.dart              # Audio/haptics preferences & onboarding state
├── screens/
│   ├── auth/                               # Login, Register, Forgot Password
│   ├── friends/                            # Invitations & Room code sharing
│   ├── game/                               # GameScreen, Canvas, Toolbar, Chat & Standings
│   ├── home/                               # Quick Play, Modes, Leaderboards & Navigation
│   ├── lobby/                              # Multiplayer lobby, ready checks, host controls
│   ├── onboarding/                         # 3-step feature walkthrough
│   ├── profile/                            # Career stats, avatar editor & account management
│   ├── results/                            # Round results modal & Podium Game Over screen
│   ├── room/                               # Create room, Join by code & Public room browser
│   ├── settings/                           # Sound, haptics, How to Play & Moderation
│   └── splash/                             # Animated pencil & stroke intro
├── services/
│   ├── auth_service.dart                   # Firebase Auth operations
│   ├── firestore_service.dart              # Cloud Firestore user stats & match archives
│   ├── game_service.dart                   # Authoritative game orchestrator & scoring
│   ├── preferences_service.dart            # Local SharedPreferences wrapper
│   └── realtime_database_service.dart      # Realtime Database streaming & presence
└── widgets/
    ├── app_logo_widget.dart                # Animated pencil & playful stroke painter
    ├── avatar_selector_sheet.dart          # 16-avatar bottom sheet selector
    └── custom_button.dart                  # Standardized accessible tactile button
```

---

## 3. Firebase Configuration & Security

The project is pre-configured with the provided Firebase project:

- **Project ID:** `borrow-e7211`
- **Application ID / Package Name:** `com.borrow.company`
- **Configuration File:** `android/app/google-services.json`

### Firebase Services Setup:
1. **Firebase Authentication:**
   - Go to [Firebase Console](https://console.firebase.google.com/) -> Build -> Authentication -> Sign-in method.
   - Enable **Anonymous** (for Instant Guest Play).
   - Enable **Email/Password** (for persistent accounts).

2. **Firebase Realtime Database:**
   - Go to Realtime Database -> Rules.
   - Deploy `database.rules.json` using the Firebase CLI:
     ```bash
     firebase deploy --only database
     ```
   - Rules guarantee that `/secret_words/{roomId}` is unreadable by guessers to prevent client-side cheating!

3. **Cloud Firestore:**
   - Go to Firestore Database -> Rules.
   - Deploy `firestore.rules`:
     ```bash
     firebase deploy --only firestore
     ```

4. **Cloud Functions (Optional Server-Side Logic):**
   - In the `functions/` directory:
     ```bash
     cd functions
     npm install
     firebase deploy --only functions
     ```

---

## 4. Building the Android Release APK Locally

To compile the Android Release APK on your local machine:

```bash
# 1. Fetch dependencies
flutter pub get

# 2. Run static analyzer (verify 0 warnings)
flutter analyze

# 3. Run all unit tests
flutter test

# 4. Build Android Release APK
flutter build apk --release
```

The compiled release APK will be located at:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## 5. Building the Android Release APK Using GitHub Actions

You can build the production Android APK without compiling locally by using GitHub Actions:

### Step 1: Create a GitHub Repository
1. Push this project to a new repository on GitHub:
   ```bash
   git init
   git add .
   git commit -m "Initial commit for Doodlio game"
   git remote add origin https://github.com/<your-username>/<your-repo-name>.git
   git branch -M main
   git push -u origin main
   ```

### Step 2: (Optional) Secure `google-services.json` in GitHub Secrets
If you prefer not to commit `google-services.json` in a public repository:
1. Base64-encode the `google-services.json` file:
   - On Windows PowerShell:
     ```powershell
     [Convert]::ToBase64String([IO.File]::ReadAllBytes("android/app/google-services.json")) | Set-Clipboard
     ```
2. In your GitHub repository:
   - Go to **Settings** -> **Secrets and variables** -> **Actions**.
   - Click **New repository secret**.
   - Name: `GOOGLE_SERVICES_JSON_BASE64`
   - Value: Paste the base64 string from your clipboard.

### Step 3: Trigger the Build Workflow
- The workflow `.github/workflows/build_apk.yml` runs automatically whenever you push to `main`.
- Or manually trigger it:
  1. Open your repository on GitHub.
  2. Navigate to the **Actions** tab.
  3. Select **Build Android Release APK** in the left sidebar.
  4. Click **Run workflow** -> **Run workflow**.

### Step 4: Download the Release APK
1. When the workflow run completes (green checkmark), click on the run title.
2. Scroll down to the **Artifacts** section at the bottom.
3. Click on **doodlio-release-apk** to download the ready-to-install ZIP containing `app-release.apk`!

---

## 6. Multiplayer Testing Checklist (2 or More Devices)

To verify the online multiplayer experience with two or more physical phones or emulators:

- [ ] **Device 1 (Host):**
  1. Launch Doodlio and tap **Quick Guest Play**. Pick an avatar and nickname (e.g., `HostAlex`).
  2. Tap **Create Room**.
  3. Configure 3 rounds, 60s drawing time, and tap **Create Room & Enter Lobby**.
  4. View the 6-character room code on screen (e.g. `ABC123`).

- [ ] **Device 2 (Guesser):**
  1. Launch Doodlio and tap **Quick Guest Play**. Pick an avatar and nickname (e.g., `GuesserBob`).
  2. Tap **Join Room**.
  3. Enter the 6-character code from Device 1 and tap **Join Lobby**.
  4. Verify that `GuesserBob` appears in real time on Device 1's lobby screen.
  5. Tap **I'm Ready!**.

- [ ] **Starting Match:**
  1. Device 1 (Host) sees that all players are ready. Tap **Start Game**.
  2. Both devices transition seamlessly into the match simultaneously.

- [ ] **Drawing Turn:**
  1. If Device 1 is the drawer: 3 word choices appear in a modal dialog.
  2. Device 1 chooses a word (e.g., `GUITAR`).
  3. Device 2 sees blanks: `_ _ _ _ _ _ (6)` and `"HostAlex is choosing a word..."` followed by drawing start.
  4. Device 1 draws on the canvas using brushes, colors, or eraser.
  5. Strokes render smoothly on Device 2's screen in real time.

- [ ] **Guessing & Scoring:**
  1. Device 2 enters an incorrect guess (e.g., `piano`). Both see the guess in the chat feed.
  2. Device 2 enters a close typo (e.g., `guitor`). Device 2 sees the **Very close!** notification.
  3. Device 2 enters `guitar`. Device 2 receives the **Solved!** banner and speed bonus points!
  4. Device 1 (drawer) receives bonus points for having their drawing solved.
  5. The round concludes automatically once all guessers solve the word or the timer expires.
  6. The **Round Results** modal reveals the word and points breakdown, before switching to the next drawer!

- [ ] **Game Over:**
  1. After all rounds complete, the Top 3 Podium and final scoreboard appear.
  2. Tap **Back to Home** to return to the main dashboard with updated career statistics saved in Firestore!

---

## 7. Web Application & Live Website Hosting

Doodlio is 100% cross-platform compatible and can run in any modern web browser (Chrome, Edge, Safari, Firefox, Mobile Browsers) sharing the exact same live Firebase Realtime Database and Firestore backend.

### Run Web Locally:
```bash
# Run with Chrome
flutter run -d chrome

# Or run on local web server
flutter run -d web-server --web-port=8080
```

### Build Web for Production:
```bash
flutter build web --release
```
The optimized web application files are generated in `build/web/`.

### Deploy Website to Firebase Hosting:
```bash
# Deploy website directly to Firebase Hosting
firebase deploy --only hosting
```
Your website will be live immediately at:
- `https://borrow-e7211.web.app`
- `https://borrow-e7211.firebaseapp.com`


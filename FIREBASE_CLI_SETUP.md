# Firebase CLI Setup Instructions

## Step 1: Login to Firebase

Run this command in your terminal (it will open a browser for authentication):
```bash
firebase login
```

## Step 2: Configure Firebase for Flutter

After logging in, run:
```bash
flutterfire configure
```

This will:
1. Show you a list of your Firebase projects
2. Let you select which project to use
3. Let you select which platforms to configure (iOS, Android, Web)
4. Automatically download and configure:
   - `android/app/google-services.json`
   - `ios/Runner/GoogleService-Info.plist`
   - `lib/firebase_options.dart` (Firebase configuration file)

## Step 3: Update main.dart (Already Done ✅)

The `main.dart` file has already been updated to initialize Firebase:
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(...);
}
```

## Step 4: Verify Setup

After running `flutterfire configure`, verify the files were created:
- ✅ `android/app/google-services.json` exists
- ✅ `ios/Runner/GoogleService-Info.plist` exists  
- ✅ `lib/firebase_options.dart` exists

Then update `main.dart` to use the generated options:
```dart
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(...);
}
```

## Alternative: Manual Setup

If CLI doesn't work, you can manually:
1. Download `google-services.json` from Firebase Console → Project Settings → Android App
2. Place it in `android/app/google-services.json`
3. Download `GoogleService-Info.plist` from Firebase Console → Project Settings → iOS App
4. Place it in `ios/Runner/GoogleService-Info.plist`
5. Create `lib/firebase_options.dart` manually or use the Firebase Console web config



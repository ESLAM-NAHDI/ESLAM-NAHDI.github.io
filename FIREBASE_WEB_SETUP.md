# Firebase Web Setup Guide

## Problem
When running the app on web, you get the error:
```
FirebaseOptions cannot be null when creating the default app.
```

This happens because Firebase requires explicit configuration options for web platforms.

## Solution

### Option 1: Using FlutterFire CLI (Recommended)

1. **Install FlutterFire CLI** (if not already installed):
   ```bash
   dart pub global activate flutterfire_cli
   ```

2. **Login to Firebase**:
   ```bash
   firebase login
   ```

3. **Configure Firebase for your project**:
   ```bash
   flutterfire configure
   ```
   
   This command will:
   - Detect your Firebase projects
   - Let you select a project
   - Generate `lib/firebase_options.dart` with the correct configuration
   - Update your Android and iOS configuration files

4. **The generated file will be automatically used** - no code changes needed!

### Option 2: Manual Configuration

If you prefer to configure manually:

1. **Get your Firebase Web App configuration**:
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Select your project
   - Go to Project Settings (gear icon)
   - Scroll down to "Your apps" section
   - Click on the Web app (or create one if it doesn't exist)
   - Copy the Firebase configuration object

2. **Update `lib/firebase_options.dart`** with your values:
   ```dart
   static const FirebaseOptions web = FirebaseOptions(
     apiKey: 'AIza...', // Your API Key
     appId: '1:123456789:web:abc123', // Your App ID
     messagingSenderId: '123456789', // Your Sender ID
     projectId: 'your-project-id', // Your Project ID
     authDomain: 'your-project-id.firebaseapp.com',
     storageBucket: 'your-project-id.appspot.com',
   );
   ```

3. **For Android and iOS**, update the corresponding sections with values from:
   - Android: `google-services.json` file
   - iOS: `GoogleService-Info.plist` file

## Getting Firebase Web Configuration

### From Firebase Console:

1. Go to Firebase Console → Your Project
2. Click the gear icon ⚙️ → Project Settings
3. Scroll to "Your apps" section
4. If you don't have a Web app, click "Add app" → Web (</> icon)
5. Register your app with a nickname (e.g., "nahdi_api_dashboard_web")
6. Copy the configuration values:
   - `apiKey`
   - `appId`
   - `messagingSenderId`
   - `projectId`
   - `authDomain`
   - `storageBucket`

### Example Configuration:

```dart
static const FirebaseOptions web = FirebaseOptions(
  apiKey: 'AIzaSyAbCdEfGhIjKlMnOpQrStUvWxYz123456',
  appId: '1:123456789012:web:abcdef123456',
  messagingSenderId: '123456789012',
  projectId: 'nahdi-api-dashboard',
  authDomain: 'nahdi-api-dashboard.firebaseapp.com',
  storageBucket: 'nahdi-api-dashboard.appspot.com',
);
```

## Verify Setup

After configuration, run your app on web:
```bash
flutter run -d chrome
```

The app should initialize Firebase without errors.

## Notes

- The `firebase_options.dart` file is already created with placeholder values
- You need to replace the placeholder values with your actual Firebase project credentials
- Make sure to add `firebase_options.dart` to `.gitignore` if it contains sensitive information, or use environment variables
- For production, consider using environment variables or a secrets management solution



# Firebase Setup Instructions

## Prerequisites
1. Create a Firebase project at https://console.firebase.google.com/
2. Add Android and iOS apps to your Firebase project

## Android Setup

1. **Download `google-services.json`**:
   - Go to Firebase Console → Project Settings → Your Android App
   - Download `google-services.json`
   - Place it in: `android/app/google-services.json`

2. **Verify build.gradle.kts files**:
   - ✅ Root `android/build.gradle.kts` - Google Services plugin added
   - ✅ App `android/app/build.gradle.kts` - Google Services plugin applied

## iOS Setup

1. **Download `GoogleService-Info.plist`**:
   - Go to Firebase Console → Project Settings → Your iOS App
   - Download `GoogleService-Info.plist`
   - Place it in: `ios/Runner/GoogleService-Info.plist`

2. **Update Podfile** (if needed):
   - The Podfile should already have the necessary configuration
   - Run: `cd ios && pod install`

## Web Setup (Optional)

1. **Add Firebase config**:
   - Go to Firebase Console → Project Settings → Your Web App
   - Copy the Firebase configuration
   - Add it to `web/index.html` if needed

## Verification

After adding the configuration files, run:
```bash
flutter pub get
flutter clean
flutter run
```

Firebase should now be initialized when the app starts!



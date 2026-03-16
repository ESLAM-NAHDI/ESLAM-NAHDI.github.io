# Firebase Migration Guide

## Overview

This guide explains how to migrate all static data and images from your app to Firebase Firestore and Firebase Storage.

## What Gets Migrated

### 📱 Screens Documentation
- All screen documentation data (Home, Checkout, Cart, Account, Nuhdeek, Health)
- Screen metadata (names, descriptions, business logic, features, etc.)
- Screenshots uploaded to Firebase Storage

### 📄 API Pages
- All API pages (Splash Screen, Login Screen, Home Screen, Cart, Checkout)
- API endpoints with cURL commands
- Screenshots uploaded to Firebase Storage

### 🖼️ Images
- All screenshots from `assets/screenshots/` folder
- Uploaded to Firebase Storage at:
  - Screens: `screenshots/screens/{screen_id}.png`
  - Pages: `screenshots/pages/{page_id}.png`

## How to Run Migration

### Option 1: Using the Migration Screen (Recommended)

1. **Run your app**:
   ```bash
   flutter run
   ```

2. **Open the sidebar** and click on **"Firebase Migration"** under the Pages section

3. **Choose migration option**:
   - **Migrate All**: Migrates both screens and pages with images
   - **Screens Only**: Migrates only screen documentation
   - **Pages Only**: Migrates only API pages

4. **Wait for completion**: The migration will show progress in the log area

5. **Verify**: Check Firebase Console to confirm data is uploaded

### Option 2: Programmatic Migration

You can also run migration programmatically:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'utils/firestore_migration_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Run migration
  final migrationHelper = FirestoreMigrationHelper();
  await migrationHelper.migrateAll();
  
  runApp(MyApp());
}
```

## Migration Process

### Step-by-Step:

1. **Reads static data** from:
   - `lib/screens_documentation/data/screens_data.dart`
   - `lib/data/api_data.dart`

2. **Uploads screenshots** to Firebase Storage:
   - Reads images from `assets/screenshots/`
   - Uploads to Firebase Storage
   - Gets download URLs

3. **Saves to Firestore**:
   - Creates documents in `screens` collection
   - Creates documents in `pages` collection
   - Links screenshot URLs to documents

4. **Generates IDs**:
   - Screen IDs: `home_screen`, `checkout_screen`, etc.
   - Page IDs: `splash_screen`, `login_screen`, etc.

## Firestore Structure

### Screens Collection
```
screens/{screen_id}
  - screenName: "Home Screen"
  - screenNameAr: "شاشة الرئيسية"
  - routeName: "/home"
  - description: "..."
  - screenshot: "https://firebasestorage.googleapis.com/..."
  - businessLogic: [...]
  - keyFeatures: [...]
  - apiEndpoints: {...}
  - ... (all other fields)
```

### Pages Collection
```
pages/{page_id}
  - name: "Splash Screen"
  - screenshot: "https://firebasestorage.googleapis.com/..."
  - apis: [
      {
        url: "api/v1/cms/...",
        method: "GET",
        curl: "curl -X GET...",
        ...
      }
    ]
```

## Firebase Storage Structure

```
screenshots/
  ├── screens/
  │   ├── home_screen.png
  │   ├── checkout_screen.png
  │   ├── cart_screen.png
  │   └── ...
  └── pages/
      ├── splash_screen.png
      ├── login_screen.png
      ├── home_screen.png
      └── ...
```

## After Migration

Once migration is complete:

1. **Your app will automatically use Firestore data** instead of static data
2. **Screenshots will load from Firebase Storage** URLs
3. **You can update data** directly in Firebase Console
4. **No code changes needed** - the app handles both static and Firestore data

## Troubleshooting

### Migration Fails

1. **Check Firebase connection**: Make sure Firebase is initialized
2. **Check Firebase permissions**: Ensure Firestore and Storage rules allow writes
3. **Check console logs**: Look for specific error messages

### Images Not Uploading

1. **Verify asset paths**: Check that screenshots exist in `assets/screenshots/`
2. **Check Firebase Storage rules**: Must allow writes
3. **Check file sizes**: Very large images might timeout

### Data Not Showing After Migration

1. **Hot restart the app**: The app needs to reload Firestore data
2. **Check Firestore console**: Verify data was saved
3. **Check network**: Ensure device can reach Firebase

## Security Rules

Make sure your Firestore and Storage rules allow the migration:

### Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /screens/{document=**} {
      allow read: if true;
      allow write: if request.auth != null; // Or remove auth requirement temporarily
    }
    match /pages/{document=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

### Storage Rules
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /screenshots/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null; // Or remove auth requirement temporarily
    }
  }
}
```

## Notes

- Migration is **idempotent**: Running it multiple times will update existing documents
- Screenshots are uploaded **every time** (they'll be overwritten)
- The app **automatically falls back** to static data if Firestore is empty
- You can **run migration multiple times** without issues



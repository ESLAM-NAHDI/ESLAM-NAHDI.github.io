# Firestore Migration Guide

This guide explains how to migrate static data to Firebase Firestore.

## Overview

All screen documentation and API page data has been migrated to use Firebase Firestore instead of static data. The app will:
1. Try to load data from Firestore first
2. Fall back to static data if Firestore is unavailable or empty

## Firestore Collections

### 1. `screens` Collection
Stores screen documentation data. Each document contains:
- `screenName` (String): Screen name in English
- `screenNameAr` (String): Screen name in Arabic
- `routeName` (String): Route name
- `description` (String): Description in English
- `descriptionAr` (String): Description in Arabic
- `filePath` (String): File path in the codebase
- `businessLogic` (Array): List of business logic items
- `businessLogicAr` (Array): List of business logic items in Arabic
- `keyFeatures` (Array): List of key features
- `keyFeaturesAr` (Array): List of key features in Arabic
- `dataModels` (Array): List of data models
- `providers` (Array): List of providers
- `useCases` (Array): List of use cases
- `childScreens` (Array): List of child screens
- `apiEndpoints` (Map): Map of API endpoint names to URLs
- `stateManagement` (String): State management approach
- `screenshot` (String): Firebase Storage URL or local asset path
- `createdAt` (Timestamp): Creation timestamp
- `updatedAt` (Timestamp): Update timestamp

### 2. `pages` Collection
Stores API page data. Each document contains:
- `name` (String): Page name
- `screenshot` (String): Firebase Storage URL or local asset path
- `apis` (Array): List of API objects, each containing:
  - `url` (String): API endpoint URL
  - `body` (String, optional): Request body
  - `description` (String): API description
  - `numberOfCalls` (Number): Number of API calls
  - `postmanLink` (String, optional): Postman collection link
  - `method` (String): HTTP method (GET, POST, etc.)
  - `curl` (String, optional): cURL command
- `createdAt` (Timestamp): Creation timestamp
- `updatedAt` (Timestamp): Update timestamp

## Firebase Storage

Screenshots are stored in Firebase Storage at:
- Path: `screenshots/{screenId}.png` or `screenshots/{pageId}.png`
- The screenshot URL is stored in the Firestore document

## Migration Steps

### Option 1: Use Migration Helper (Recommended)

1. Create a temporary migration screen or run migration in `main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'utils/firestore_migration_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  
  // Run migration
  final migrationHelper = FirestoreMigrationHelper();
  await migrationHelper.migrateAll();
  
  runApp(MyApp());
}
```

2. Run the app once to migrate all data
3. Remove the migration code after successful migration

### Option 2: Manual Migration via Firebase Console

1. Go to Firebase Console → Firestore Database
2. Create collections `screens` and `pages`
3. Copy data from static files (`screens_data.dart` and `api_data.dart`) to Firestore
4. Upload screenshots to Firebase Storage
5. Update screenshot URLs in Firestore documents

## Uploading Screenshots

### Using Firebase Storage Service

```dart
import 'services/firebase_storage_service.dart';

final storageService = ref.read(firebaseStorageServiceProvider);

// Upload from image picker
final url = await storageService.uploadScreenshotFromPicker('screen-id');

// Or upload from file
final file = File('path/to/image.png');
final url = await storageService.uploadScreenshot('screen-id', file);
```

### Using Firebase Console

1. Go to Firebase Console → Storage
2. Create folder `screenshots/`
3. Upload images as `{screenId}.png` or `{pageId}.png`
4. Copy the download URL
5. Update the `screenshot` field in Firestore document

## Firestore Security Rules

Make sure your Firestore security rules allow read access:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow read access to screens and pages
    match /screens/{document=**} {
      allow read: if true;
      allow write: if request.auth != null; // Only authenticated users can write
    }
    match /pages/{document=**} {
      allow read: if true;
      allow write: if request.auth != null; // Only authenticated users can write
    }
  }
}
```

## Firebase Storage Security Rules

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /screenshots/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null; // Only authenticated users can write
    }
  }
}
```

## Testing

After migration:
1. Verify data loads from Firestore (check Firebase Console logs)
2. Verify screenshots display correctly (both Firebase Storage URLs and local assets)
3. Test fallback to static data when Firestore is unavailable

## Notes

- The app maintains backward compatibility with static data
- Screenshots can be either Firebase Storage URLs or local asset paths
- All API cURL commands are stored in Firestore
- Screen IDs are automatically generated by Firestore



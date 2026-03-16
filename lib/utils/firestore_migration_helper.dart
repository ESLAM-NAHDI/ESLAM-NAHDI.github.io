import '../services/firestore_service.dart';
import '../screens_documentation/data/screens_data.dart';
import '../data/api_data.dart';
import '../screens_documentation/domain/models/screen_info_model.dart';
import '../models/api_info.dart';

/// Helper class to migrate static data to Firestore
/// Run this once to upload all static data to Firebase
class FirestoreMigrationHelper {
  final FirestoreService _firestoreService = FirestoreService();
  
  // Note: Image uploads are disabled to avoid Firebase Storage billing requirements
  // Screenshots will use local asset paths instead

  /// Generate a unique ID from screen name
  String _generateScreenId(String screenName) {
    return screenName.toLowerCase().replaceAll(' ', '_');
  }

  /// Generate a unique ID from page name
  String _generatePageId(String pageName) {
    return pageName.toLowerCase().replaceAll(' ', '_');
  }

  /// Migrate all screens from static data to Firestore (data only, no images)
  Future<void> migrateScreens() async {
    try {
      print('\n🔍 Checking static screens data...');
      final staticScreens = ScreensData.getAllScreens();
      print('📱 Found ${staticScreens.length} screens in static data');
      
      if (staticScreens.isEmpty) {
        print('⚠️ No screens found in static data!');
        print('⚠️ Cannot migrate - no source data available');
        throw Exception('No screens found in static data. Check ScreensData.getAllScreens()');
      }
      
      // Log first few screen names for verification
      print('📋 Sample screens: ${staticScreens.take(3).map((s) => s.screenName).join(", ")}...');
      print('\n📱 Migrating ${staticScreens.length} screens to Firestore (data only)...\n');
      
      int successCount = 0;
      int failCount = 0;
      
      for (final screen in staticScreens) {
        try {
          // Generate ID from screen name
          final screenId = _generateScreenId(screen.screenName);
          print('🔄 Processing screen: ${screen.screenName} (ID: $screenId)');
          
          // Keep original screenshot path (don't upload to Storage)
          // This allows the app to use local assets or existing URLs
          String? screenshotPath = screen.screenshot;
          
          // Create screen with ID and original screenshot path
          final screenWithId = ScreenInfoModel(
            id: screenId,
            screenName: screen.screenName,
            screenNameAr: screen.screenNameAr,
            routeName: screen.routeName,
            description: screen.description,
            descriptionAr: screen.descriptionAr,
            filePath: screen.filePath,
            businessLogic: screen.businessLogic,
            businessLogicAr: screen.businessLogicAr,
            keyFeatures: screen.keyFeatures,
            keyFeaturesAr: screen.keyFeaturesAr,
            dataModels: screen.dataModels,
            providers: screen.providers,
            useCases: screen.useCases,
            childScreens: screen.childScreens,
            apiEndpoints: screen.apiEndpoints,
            stateManagement: screen.stateManagement,
            screenshot: screenshotPath, // Keep original path
          );
          
          await _firestoreService.addOrUpdateScreen(screenWithId);
          print('✓ Migrated screen: ${screen.screenName} (ID: $screenId)');
          successCount++;
          if (screenshotPath != null) {
            print('  └─ Screenshot path: $screenshotPath (local asset)');
          }
          
          // Small delay to avoid rate limiting
          await Future.delayed(const Duration(milliseconds: 100));
        } catch (e, stackTrace) {
          print('✗ Failed to migrate screen ${screen.screenName}: $e');
          print('  Stack trace: $stackTrace');
          failCount++;
          // Continue with next screen even if one fails
        }
      }
      
      print('\n✅ Screen migration completed!');
      print('  ✓ Success: $successCount');
      print('  ✗ Failed: $failCount');
      print('  Total: ${staticScreens.length}\n');
    } catch (e, stackTrace) {
      print('❌ Critical error in migrateScreens: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Migrate all pages from static data to Firestore (data only, no images)
  Future<void> migratePages() async {
    final staticPages = ApiData.getPages();
    print('\n📄 Migrating ${staticPages.length} pages to Firestore (data only)...\n');
    
    for (final page in staticPages) {
      try {
        // Generate ID from page name
        final pageId = _generatePageId(page.name);
        
        // Keep original screenshot path (don't upload to Storage)
        // This allows the app to use local assets or existing URLs
        String? screenshotPath = page.screenshot;
        
        // Create page with ID and original screenshot path
        final pageWithId = PageInfo(
          id: pageId,
          name: page.name,
          screenshot: screenshotPath, // Keep original path
          apis: page.apis,
        );
        
        await _firestoreService.addOrUpdatePage(pageWithId);
        print('✓ Migrated page: ${page.name} (ID: $pageId)');
        if (screenshotPath != null) {
          print('  └─ Screenshot path: $screenshotPath (local asset)');
        }
        print('  └─ APIs: ${page.apis.length}');
      } catch (e) {
        print('✗ Failed to migrate page ${page.name}: $e');
      }
    }
    
    print('\n✅ Page migration completed!\n');
  }

  /// Migrate all data (screens + pages) - Data only, no images
  Future<void> migrateAll() async {
    print('🚀 Starting migration to Firebase (data only)...\n');
    print('=' * 50);
    print('ℹ️  Note: Images will NOT be uploaded (using local assets)');
    print('=' * 50);
    
    await migrateScreens();
    await migratePages();
    
    print('=' * 50);
    print('🎉 All migrations completed successfully!');
    print('\nYour data is now in Firebase:');
    print('  • Screens: Firestore collection "screens"');
    print('  • Pages: Firestore collection "pages"');
    print('  • Screenshots: Using local assets (not uploaded to Storage)');
  }
}

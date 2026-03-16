import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../screens_documentation/domain/models/screen_info_model.dart';
import '../models/api_info.dart';

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Screens Collection
  CollectionReference get _screensCollection => _firestore.collection('screens');
  
  // Pages Collection (for API data)
  CollectionReference get _pagesCollection => _firestore.collection('pages');

  // Get all screens from Firestore
  Future<List<ScreenInfoModel>> getAllScreens() async {
    try {
      print('🔍 Fetching screens from Firestore collection: screens');
      
      // First, try to get all documents without ordering to see if collection exists
      QuerySnapshot querySnapshot;
      try {
        // Try ordering by createdAt first
        querySnapshot = await _screensCollection.orderBy('createdAt', descending: true).get();
        print('✅ Ordered by createdAt');
      } catch (e) {
        // If createdAt doesn't exist, try ordering by screenName
        print('⚠️ createdAt field not found, trying screenName ordering');
        try {
          querySnapshot = await _screensCollection.orderBy('screenName').get();
          print('✅ Ordered by screenName');
        } catch (e2) {
          // If ordering fails, just get all documents
          print('⚠️ Ordering failed, fetching all documents without order');
          querySnapshot = await _screensCollection.get();
        }
      }
      
      print('📊 Found ${querySnapshot.docs.length} documents in screens collection');
      
      if (querySnapshot.docs.isEmpty) {
        print('⚠️ Screens collection is empty!');
        print('💡 Run "Screens Only" migration from Firebase Migration screen');
        return [];
      }
      
      final screens = querySnapshot.docs.map((doc) {
        try {
          return _screenFromFirestore(doc);
        } catch (e) {
          print('❌ Error converting document ${doc.id}: $e');
          return null;
        }
      }).whereType<ScreenInfoModel>().toList();
      
      print('✅ Successfully converted ${screens.length} screens from Firestore');
      return screens;
    } catch (e, stackTrace) {
      print('❌ Error fetching screens: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  // Get screen by ID
  Future<ScreenInfoModel?> getScreenById(String screenId) async {
    try {
      final doc = await _screensCollection.doc(screenId).get();
      if (doc.exists) {
        return _screenFromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error fetching screen: $e');
      return null;
    }
  }

  // Get all pages from Firestore
  Future<List<PageInfo>> getAllPages() async {
    try {
      final querySnapshot = await _pagesCollection.orderBy('name').get();
      return querySnapshot.docs.map((doc) => _pageFromFirestore(doc)).toList();
    } catch (e) {
      print('Error fetching pages: $e');
      return [];
    }
  }

  // Get page by name
  Future<PageInfo?> getPageByName(String pageName) async {
    try {
      final querySnapshot = await _pagesCollection.where('name', isEqualTo: pageName).limit(1).get();
      if (querySnapshot.docs.isNotEmpty) {
        return _pageFromFirestore(querySnapshot.docs.first);
      }
      return null;
    } catch (e) {
      print('Error fetching page: $e');
      return null;
    }
  }

  // Convert Firestore document to ScreenInfoModel
  ScreenInfoModel _screenFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ScreenInfoModel(
      id: doc.id,
      screenName: data['screenName'] ?? '',
      screenNameAr: data['screenNameAr'] ?? '',
      routeName: data['routeName'] ?? '',
      description: data['description'] ?? '',
      descriptionAr: data['descriptionAr'] ?? '',
      filePath: data['filePath'] ?? '',
      businessLogic: List<String>.from(data['businessLogic'] ?? []),
      businessLogicAr: List<String>.from(data['businessLogicAr'] ?? []),
      keyFeatures: List<String>.from(data['keyFeatures'] ?? []),
      keyFeaturesAr: List<String>.from(data['keyFeaturesAr'] ?? []),
      dataModels: List<String>.from(data['dataModels'] ?? []),
      providers: List<String>.from(data['providers'] ?? []),
      useCases: List<String>.from(data['useCases'] ?? []),
      childScreens: List<String>.from(data['childScreens'] ?? []),
      apiEndpoints: Map<String, String>.from(data['apiEndpoints'] ?? {}),
      stateManagement: data['stateManagement'] ?? '',
      screenshot: data['screenshot'] ?? data['screenshotUrl'], // Support both field names
    );
  }

  // Convert Firestore document to PageInfo
  PageInfo _pageFromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PageInfo(
      id: doc.id,
      name: data['name'] ?? '',
      screenshot: data['screenshot'] ?? data['screenshotUrl'],
      apis: (data['apis'] as List<dynamic>?)
          ?.map((api) => _apiFromMap(api as Map<String, dynamic>))
          .toList() ?? [],
    );
  }

  // Convert map to ApiInfo
  ApiInfo _apiFromMap(Map<String, dynamic> map) {
    return ApiInfo(
      url: map['url'] ?? '',
      body: map['body'],
      description: map['description'] ?? '',
      numberOfCalls: map['numberOfCalls'] ?? 0,
      postmanLink: map['postmanLink'],
      method: map['method'] ?? 'GET',
      curl: map['curl'],
    );
  }

  // Add or update screen
  Future<void> addOrUpdateScreen(ScreenInfoModel screen) async {
    try {
      final screenData = _screenToFirestore(screen);
      final screenId = screen.id ?? _generateIdFromName(screen.screenName);
      
      print('💾 Saving screen to Firestore: ${screen.screenName} (ID: $screenId)');
      
      await _screensCollection.doc(screenId).set(screenData, SetOptions(merge: true));
      
      print('✅ Successfully saved screen: ${screen.screenName}');
    } catch (e, stackTrace) {
      print('❌ Error saving screen ${screen.screenName}: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
  
  // Helper to generate ID from screen name
  String _generateIdFromName(String name) {
    return name.toLowerCase().replaceAll(' ', '_');
  }

  // Add or update page
  Future<void> addOrUpdatePage(PageInfo page) async {
    try {
      final pageData = _pageToFirestore(page);
      if (page.id != null && page.id!.isNotEmpty) {
        await _pagesCollection.doc(page.id).set(pageData, SetOptions(merge: true));
      } else {
        await _pagesCollection.add(pageData);
      }
    } catch (e) {
      print('Error saving page: $e');
      rethrow;
    }
  }

  // Convert ScreenInfoModel to Firestore map
  Map<String, dynamic> _screenToFirestore(ScreenInfoModel screen) {
    return {
      'screenName': screen.screenName,
      'screenNameAr': screen.screenNameAr,
      'routeName': screen.routeName,
      'description': screen.description,
      'descriptionAr': screen.descriptionAr,
      'filePath': screen.filePath,
      'businessLogic': screen.businessLogic,
      'businessLogicAr': screen.businessLogicAr,
      'keyFeatures': screen.keyFeatures,
      'keyFeaturesAr': screen.keyFeaturesAr,
      'dataModels': screen.dataModels,
      'providers': screen.providers,
      'useCases': screen.useCases,
      'childScreens': screen.childScreens,
      'apiEndpoints': screen.apiEndpoints,
      'stateManagement': screen.stateManagement,
      'screenshot': screen.screenshot,
      'updatedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(), // Always set createdAt for new documents
    };
  }

  // Convert PageInfo to Firestore map
  Map<String, dynamic> _pageToFirestore(PageInfo page) {
    return {
      'name': page.name,
      'screenshot': page.screenshot,
      'apis': page.apis.map((api) => _apiToMap(api)).toList(),
      'updatedAt': FieldValue.serverTimestamp(),
      if (page.id == null) 'createdAt': FieldValue.serverTimestamp(),
    };
  }

  // Convert ApiInfo to map
  Map<String, dynamic> _apiToMap(ApiInfo api) {
    return {
      'url': api.url,
      'body': api.body,
      'description': api.description,
      'numberOfCalls': api.numberOfCalls,
      'postmanLink': api.postmanLink,
      'method': api.method,
      'curl': api.curl,
    };
  }
}


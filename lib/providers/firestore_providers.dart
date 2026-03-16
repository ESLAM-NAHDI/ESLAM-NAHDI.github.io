import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/firestore_service.dart';
import '../screens_documentation/domain/models/screen_info_model.dart';
import '../models/api_info.dart';
import '../data/api_data.dart';

// Provider for all screens
final screensProvider = FutureProvider<List<ScreenInfoModel>>((ref) async {
  final service = ref.watch(firestoreServiceProvider);
  return await service.getAllScreens();
});

// Provider for a specific screen by ID
final screenByIdProvider = FutureProvider.family<ScreenInfoModel?, String>((ref, screenId) async {
  final service = ref.watch(firestoreServiceProvider);
  return await service.getScreenById(screenId);
});

// Provider for all pages
final pagesProvider = FutureProvider<List<PageInfo>>((ref) async {
  final service = ref.watch(firestoreServiceProvider);
  List<PageInfo> firestorePages;
  try {
    firestorePages = await service.getAllPages();
  } catch (e) {
    firestorePages = [];
  }
  // Fallback to static ApiData when Firestore is empty
  if (firestorePages.isEmpty) {
    return ApiData.getPages();
  }
  // Merge screenshot paths and APIs from static ApiData (local/source-of-truth takes priority)
  final staticPages = ApiData.getPages();
  final staticPageMap = {
    for (final p in staticPages) p.name.toLowerCase(): p
  };
  // Case-insensitive lookup for screenshot (Firestore name may differ slightly)
  String? _getLocalScreenshot(String pageName) {
    final staticPage = staticPageMap[pageName.toLowerCase()];
    if (staticPage?.screenshot != null && staticPage!.screenshot!.isNotEmpty) {
      return staticPage.screenshot;
    }
    return null;
  }
  // Prefer Firestore APIs when page exists in Firestore (user can update cURL etc.)
  // Only use static ApiData for pages not yet migrated to Firestore
  List<ApiInfo> _getApisForPage(PageInfo firestorePage) {
    // If we have Firestore data (page has id), use it - user updates must be preserved
    if (firestorePage.id != null &&
        firestorePage.id!.isNotEmpty &&
        firestorePage.apis.isNotEmpty) {
      return firestorePage.apis;
    }
    // Fallback to static ApiData for pages without Firestore APIs (not yet migrated)
    final key = firestorePage.name.toLowerCase();
    var staticPage = staticPageMap[key];
    if (staticPage == null && key.contains('cart')) {
      staticPage = staticPageMap['cart'];
    }
    if (staticPage != null && staticPage.apis.isNotEmpty) {
      return staticPage.apis;
    }
    return firestorePage.apis;
  }
  final mergedPages = firestorePages.map((page) {
    final localScreenshot = _getLocalScreenshot(page.name);
    final apis = _getApisForPage(page);
    return PageInfo(
      id: page.id,
      name: page.name,
      apis: apis,
      screenshot: localScreenshot ?? page.screenshot,
    );
  }).toList();

  // Add ApiData pages missing from Firestore (e.g. Onboarding Screen if not migrated)
  final firestoreNames = mergedPages.map((p) => p.name.toLowerCase()).toSet();
  for (final staticPage in staticPages) {
    if (!firestoreNames.contains(staticPage.name.toLowerCase())) {
      mergedPages.add(staticPage);
    }
  }
  return mergedPages;
});

// Provider for a specific page by name
final pageByNameProvider = FutureProvider.family<PageInfo?, String>((ref, pageName) async {
  final service = ref.watch(firestoreServiceProvider);
  return await service.getPageByName(pageName);
});



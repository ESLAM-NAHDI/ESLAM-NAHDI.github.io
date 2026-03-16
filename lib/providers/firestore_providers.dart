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
  // Prefer ApiData APIs when a matching page exists (source of truth in code)
  List<ApiInfo> _getApisForPage(PageInfo firestorePage) {
    final key = firestorePage.name.toLowerCase();
    var staticPage = staticPageMap[key];
    // Fallback: Firestore may have "Cart Screen" etc. - match by prefix for known pages
    if (staticPage == null && key.contains('cart')) {
      staticPage = staticPageMap['cart'];
    }
    if (staticPage != null && staticPage.apis.isNotEmpty) {
      return staticPage.apis; // Use ApiData APIs (includes Bazaar Voice, etc.)
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



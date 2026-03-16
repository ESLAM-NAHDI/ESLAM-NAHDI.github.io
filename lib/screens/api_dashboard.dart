import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../data/api_data.dart';
import '../models/api_info.dart';
import '../providers/app_providers.dart';
import '../providers/firestore_providers.dart';
import 'api_detail_page.dart';

class ApiDashboard extends ConsumerStatefulWidget {
  const ApiDashboard({super.key});

  @override
  ConsumerState<ApiDashboard> createState() => _ApiDashboardState();
}

class _ApiDashboardState extends ConsumerState<ApiDashboard> {
  List<PageInfo> pages = [];
  late PlutoGridStateManager stateManager;
  bool _isNavigating = false;
  bool _isLoadingPages = true; // Track loading state

  @override
  void initState() {
    super.initState();
    // Load from Firestore first - prioritize Firestore data
    _loadPagesFromFirestore();
  }

  Future<void> _loadPagesFromFirestore() async {
    setState(() {
      _isLoadingPages = true;
    });
    
    try {
      // Load from Firestore ONLY - no static fallback
      final firestorePages = await ref.read(pagesProvider.future);
      if (mounted) {
        if (firestorePages.isNotEmpty) {
          print('✅ Using ${firestorePages.length} pages from Firestore');
          
          // Debug: Check how many pages have cURL commands
          final pagesWithCurlCount = firestorePages.where((page) {
            return page.apis.any((api) => api.curl != null && api.curl!.isNotEmpty);
          }).length;
          print('📊 Pages with cURL commands: $pagesWithCurlCount out of ${firestorePages.length}');
          
          // Debug: List all page names
          print('📄 Available pages: ${firestorePages.map((p) => p.name).join(", ")}');
          
          setState(() {
            pages = firestorePages;
            _isLoadingPages = false;
          });
          _initializeSelectedPage();
        } else {
          // Firestore is empty - no static fallback
          print('⚠️ Firestore pages collection is empty - no data available');
          setState(() {
            pages = []; // Empty list - no static data
            _isLoadingPages = false;
          });
        }
      }
    } catch (e) {
      // On error, return empty list (no static fallback)
      print('❌ Error loading pages from Firestore: $e');
      print('⚠️ No data available - check Firestore connection');
      if (mounted) {
        setState(() {
          pages = []; // Empty list - no static data
          _isLoadingPages = false;
        });
      }
    }
  }

  void _initializeSelectedPage() {
    if (pages.isNotEmpty) {
      // Delay provider modification until after build
      Future(() {
        if (mounted) {
          final selectedPage = ref.read(selectedPageProvider);
          // Use all pages, sorted
          final allPagesSorted = List<PageInfo>.from(
            pages.where((p) => p.name != 'Authentication'),
          );
          _sortPages(allPagesSorted);
          
          // Check if selected page exists, if not set to first page
          if (selectedPage.isEmpty || 
              !allPagesSorted.any((page) => page.name == selectedPage)) {
            if (allPagesSorted.isNotEmpty) {
              print('🎯 Setting selected page to: ${allPagesSorted.first.name}');
              ref.read(selectedPageProvider.notifier).state = allPagesSorted.first.name;
            }
          }
        }
      });
    }
  }

  PageInfo? get selectedPageInfo {
    final selectedPage = ref.read(selectedPageProvider);
    if (selectedPage.isEmpty) return null;
    return pages.firstWhere(
      (page) => page.name == selectedPage,
      orElse: () => pages.first,
    );
  }

  // Get pages that have at least one API with cURL, sorted in specific order
  // If no pages have cURL, show all pages instead
  List<PageInfo> get pagesWithCurl {
    final pagesWithCurlList = pages.where((page) {
      return page.apis.any((api) => api.curl != null && api.curl!.isNotEmpty);
    }).toList();
    
    // If no pages have cURL, show all pages (for debugging/migration)
    if (pagesWithCurlList.isEmpty && pages.isNotEmpty) {
      print('⚠️ No pages have cURL commands. Showing all pages instead.');
      print('💡 Check if cURL commands were saved correctly during migration.');
      // Return all pages sorted
      final allPages = List<PageInfo>.from(pages);
      _sortPages(allPages);
      return allPages;
    }
    
    // Sort pages according to the defined order
    _sortPages(pagesWithCurlList);
    
    return pagesWithCurlList;
  }
  
  // Helper method to sort pages
  void _sortPages(List<PageInfo> pagesList) {
    // Define the desired sort order: Splash -> Login -> Home -> Cart -> Checkout
    final sortOrder = [
      'Splash Screen',
      'Onboarding Screen',
      'Login Screen',
      'Register Screen',
      'Forgot Password Screen',
      'Home Screen',
      'Home Page', // Alternative name - matches Firestore data
      'Cart',
      'Checkout',
      'Product Detail (PDP)',
      'Orders',
      'My Account',
      'Search',
      'Wishlist',
      'Shipping & Address',
    ];
    
    pagesList.sort((a, b) {
      final indexA = sortOrder.indexOf(a.name);
      final indexB = sortOrder.indexOf(b.name);
      
      // If both are in the sort order, sort by their position
      if (indexA != -1 && indexB != -1) {
        return indexA.compareTo(indexB);
      }
      // If only A is in sort order, A comes first
      if (indexA != -1) return -1;
      // If only B is in sort order, B comes first
      if (indexB != -1) return 1;
      // If neither is in sort order, maintain alphabetical order
      return a.name.compareTo(b.name);
    });
  }

  Color _getMethodColor(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return const Color(0xFF10B981);
      case 'POST':
        return const Color(0xFFFFC107); // Yellow color
      case 'PUT':
        return const Color(0xFFF59E0B);
      case 'DELETE':
        return const Color(0xFFEF4444);
      case 'PATCH':
        return const Color(0xFF8B5CF6);
      default:
        return Colors.grey;
    }
  }

  void _navigateToDetail(ApiInfo api) {
    if (_isNavigating) return; // Prevent duplicate navigation
    
    _isNavigating = true;
    final selectedPage = ref.read(selectedPageProvider);
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ApiDetailPage(
          api: api,
          pageName: selectedPage.isEmpty ? 'Unknown' : selectedPage,
        ),
      ),
    ).then((_) {
      // Reset navigation flag when returning from detail page
      if (mounted) {
        _isNavigating = false;
      }
    });
  }

  /// Returns the set of "url|method" keys that appear more than once (duplicated requests)
  Set<String> _computeDuplicatedKeys(List<ApiInfo> apis) {
    final countMap = <String, int>{};
    for (final api in apis) {
      final key = '${api.url}|${api.method}';
      countMap[key] = (countMap[key] ?? 0) + 1;
    }
    return countMap.entries
        .where((e) => e.value > 1)
        .map((e) => e.key)
        .toSet();
  }

  List<PlutoColumn> _buildColumns(List<ApiInfo> filteredApis) {
    final duplicatedKeys = _computeDuplicatedKeys(filteredApis);

    return [
      PlutoColumn(
        title: 'Method',
        field: 'method',
        type: PlutoColumnType.text(),
        width: 120,
        enableSorting: true,
        enableEditingMode: false,
        renderer: (rendererContext) {
          final method = rendererContext.cell.value.toString();
          final methodColor = _getMethodColor(method);
          return Container(
            alignment: Alignment.center,
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: methodColor,
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: methodColor.withOpacity(0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Text(
              method,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'URL',
        field: 'url',
        type: PlutoColumnType.text(),
        width: 500,
        enableSorting: true,
        enableEditingMode: false,
        renderer: (rendererContext) {
          final url = rendererContext.cell.value.toString();
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Tooltip(
              message: url,
              child: Text(
                url,
                style: const TextStyle(
                  fontSize: 13,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Description',
        field: 'description',
        type: PlutoColumnType.text(),
        width: 400,
        enableSorting: true,
        enableEditingMode: false,
        renderer: (rendererContext) {
          final description = rendererContext.cell.value.toString();
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            padding: const EdgeInsets.all(12),
            child: Text(
              description,
              style: TextStyle(
                fontSize: 15,
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.9),
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Calls',
        field: 'calls',
        type: PlutoColumnType.number(),
        width: 150,
        enableSorting: true,
        enableEditingMode: false,
        renderer: (rendererContext) {
          final rowIdx = rendererContext.rowIdx;
          final isDuplicated = rowIdx >= 0 &&
              rowIdx < filteredApis.length &&
              duplicatedKeys.contains('${filteredApis[rowIdx].url}|${filteredApis[rowIdx].method}');

          if (isDuplicated) {
            const dupColor = Color(0xFFFF8C00); // Amber/Orange for duplicated
            return Container(
              width: double.infinity,
              height: double.infinity,
              alignment: Alignment.center,
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    dupColor.withOpacity(0.2),
                    dupColor.withOpacity(0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: dupColor.withOpacity(0.3), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.copy_all, size: 16, color: dupColor),
                  const SizedBox(width: 6),
                  Text(
                    'Dup',
                    style: TextStyle(
                      color: dupColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ],
              ),
            );
          }

          final calls = rendererContext.cell.value ?? 0;
          final isHighCalls = calls > 1;
          final isLowCalls = calls < 1;
          final color = isLowCalls || isHighCalls ? Colors.red : Colors.blue;

          return Container(
            width: double.infinity,
            height: double.infinity,
            alignment: Alignment.center,
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withOpacity(0.2),
                  color.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isLowCalls ? Icons.trending_down : (isHighCalls ? Icons.warning : Icons.trending_up),
                  size: 16,
                  color: color[300],
                ),
                const SizedBox(width: 6),
                Text(
                  calls.toString(),
                  style: TextStyle(
                    color: color[300],
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        },
      ),
      PlutoColumn(
        title: 'Actions',
        field: 'actions',
        type: PlutoColumnType.text(),
        width: 220,
        enableSorting: false,
        enableEditingMode: false,
        renderer: (rendererContext) {
          final pageInfo = selectedPageInfo;
          final filteredApis = pageInfo != null
              ? pageInfo.apis.where((api) => api.curl != null && api.curl!.isNotEmpty).toList()
              : <ApiInfo>[];
          final rowIndex = rendererContext.rowIdx;
          final api = rowIndex >= 0 && rowIndex < filteredApis.length
              ? filteredApis[rowIndex]
              : null;
          final hasCurl = api?.curl != null && api!.curl!.isNotEmpty;

          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (hasCurl)
                    Tooltip(
                      message: 'Copy cURL',
                      child: IconButton(
                        onPressed: () {
                          Clipboard.setData(ClipboardData(text: api.curl ?? ''));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('cURL copied to clipboard'),
                              duration: Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        icon: const Icon(Icons.copy, size: 16),
                        style: IconButton.styleFrom(
                          padding: const EdgeInsets.all(4),
                          minimumSize: const Size(28, 28),
                        ),
                      ),
                    ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        if (api != null) _navigateToDetail(api);
                      },
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.primary.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.visibility, size: 14, color: Colors.white),
                            SizedBox(width: 4),
                            Text(
                              'View',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ];
  }

  List<PlutoRow> _buildRows(List<ApiInfo> apis) {
    return apis.map((api) {
      return PlutoRow(
        cells: {
          'method': PlutoCell(value: api.method),
          'url': PlutoCell(value: api.url),
          'description': PlutoCell(value: api.description),
          'calls': PlutoCell(value: api.numberOfCalls),
          'actions': PlutoCell(value: 'View'),
        },
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedPage = ref.watch(selectedPageProvider);
    
    // Show all pages in dropdown (not just those with cURL), excluding Authentication
    final allPagesSorted = List<PageInfo>.from(
      pages.where((p) => p.name != 'Authentication'),
    );
    _sortPages(allPagesSorted);
    
    print('🔍 Build: pages.length = ${pages.length}, allPagesSorted.length = ${allPagesSorted.length}');
    print('🔍 Build: _isLoadingPages = $_isLoadingPages');
    
    // Ensure selectedPage is valid or use first page
    final validSelectedPage = (selectedPage.isNotEmpty && 
        allPagesSorted.any((page) => page.name == selectedPage))
        ? selectedPage
        : (allPagesSorted.isNotEmpty ? allPagesSorted.first.name : '');
    
    print('🔍 Build: validSelectedPage = "$validSelectedPage"');
    final pageInfo = selectedPageInfo;
    
    // Filter APIs to only show those with cURL commands
    final filteredApis = pageInfo != null
        ? pageInfo.apis.where((api) => api.curl != null && api.curl!.isNotEmpty).toList()
        : <ApiInfo>[];

    return Row(
      children: [
        // Left Side - Dropdown and Table
        Expanded(
          child: Column(
            children: [
              // Dropdown Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: const BoxDecoration(
                  color: Colors.black,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Select Page',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _isLoadingPages
                        ? Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey[700]!,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Loading pages...',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey[700]!,
                              ),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: validSelectedPage.isNotEmpty ? validSelectedPage : null,
                                isExpanded: true,
                                icon: const Icon(
                                  Icons.arrow_drop_down,
                                  color: Colors.white,
                                ),
                                iconSize: 28,
                                dropdownColor: theme.colorScheme.surface,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                items: allPagesSorted.isEmpty
                                    ? [
                                        DropdownMenuItem<String>(
                                          value: null,
                                          enabled: false,
                                          child: Text(
                                            'No pages available',
                                            style: TextStyle(
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                      ]
                                    : allPagesSorted.map((page) {
                                        // Check if page has cURL commands
                                        final hasCurl = page.apis.any((api) => api.curl != null && api.curl!.isNotEmpty);
                                        return DropdownMenuItem<String>(
                                          value: page.name,
                                          child: Row(
                                            children: [
                                              Icon(
                                                hasCurl ? Icons.dashboard : Icons.dashboard_outlined,
                                                color: hasCurl 
                                                    ? theme.colorScheme.onSurface 
                                                    : theme.colorScheme.onSurface.withOpacity(0.6),
                                                size: 20,
                                              ),
                                              const SizedBox(width: 12),
                                              Expanded(
                                                child: Text(
                                                  page.name,
                                                  style: TextStyle(
                                                    color: hasCurl 
                                                        ? theme.colorScheme.onSurface 
                                                        : theme.colorScheme.onSurface.withOpacity(0.6),
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              if (!hasCurl)
                                                Padding(
                                                  padding: const EdgeInsets.only(left: 8),
                                                  child: Text(
                                                    '(no cURL)',
                                                    style: TextStyle(
                                                      color: Colors.grey[500],
                                                      fontSize: 11,
                                                      fontStyle: FontStyle.italic,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),
                                        );
                                      }).toList(),
                                onChanged: allPagesSorted.isEmpty
                                    ? null
                                    : (String? newValue) {
                                        if (newValue != null) {
                                          ref.read(selectedPageProvider.notifier).state = newValue;
                                        }
                                      },
                              ),
                            ),
                          ),
                        if (pageInfo != null) ...[
                          const SizedBox(height: 12),
                          // Description - Simple text aligned to right
                          Align(
                            alignment: Alignment.centerRight,
                            child: Text(
                              '${filteredApis.length} API${filteredApis.length != 1 ? 's' : ''} found',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),

                  // Table Content
                  Expanded(
                    child: pageInfo == null
                        ? Center(
                            child: Text(
                              'Please select a page',
                              style: TextStyle(
                                color: theme.colorScheme.onSurface.withOpacity(0.6),
                              ),
                            ),
                          )
                        : filteredApis.isEmpty
                            ? Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.inbox,
                                      size: 64,
                                      color: theme.colorScheme.onSurface.withOpacity(0.4),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No APIs with cURL found for this page',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Container(
                                width: double.infinity,
                                height: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                child: PlutoGrid(
                                  key: ValueKey(selectedPage),
                                  mode: PlutoGridMode.readOnly,
                                  columns: _buildColumns(filteredApis),
                                  rows: _buildRows(filteredApis),
                              onLoaded: (PlutoGridOnLoadedEvent event) {
                                stateManager = event.stateManager;
                                stateManager.setSelectingMode(PlutoGridSelectingMode.row);
                                stateManager.setShowColumnFilter(true);
                              },
                              configuration: PlutoGridConfiguration(
                                columnSize: PlutoGridColumnSizeConfig(
                                  autoSizeMode: PlutoAutoSizeMode.scale,
                                  resizeMode: PlutoResizeMode.normal,
                                ),
                                style: PlutoGridStyleConfig(
                                  gridBackgroundColor: theme.scaffoldBackgroundColor,
                                  activatedColor: theme.colorScheme.primary.withOpacity(0.15),
                                  activatedBorderColor: theme.colorScheme.primary,
                                  inactivatedBorderColor: Colors.transparent,
                                  checkedColor: theme.colorScheme.primary.withOpacity(0.2),
                                  rowColor: theme.colorScheme.surface.withOpacity(0.3),
                                  oddRowColor: theme.colorScheme.surface.withOpacity(0.1),
                                  columnTextStyle: TextStyle(
                                    color: theme.colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    letterSpacing: 0.5,
                                  ),
                                  cellTextStyle: TextStyle(
                                    color: theme.colorScheme.onSurface,
                                  ),
                                  columnHeight: 60,
                                  rowHeight: 80,
                                  borderColor: Colors.transparent,
                                  gridBorderColor: Colors.transparent,
                                  enableRowColorAnimation: false,
                                  defaultCellPadding: EdgeInsets.zero,
                                ),
                              ),
                              noRowsWidget: Center(
                                child: Text(
                                  'No APIs found',
                                  style: TextStyle(
                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                                  ),
                                ),
                              ),
                            ),
                          ),
              ),
            ],
          ),
        ),

        // Right Side - Screenshot (full height from top)
        if (pageInfo != null && ref.watch(showScreenshotProvider)) ...[
          Container(
            width: 400,
            decoration: BoxDecoration(
              color: Colors.grey[900],
            ),
            child: Builder(
              builder: (context) {
                final screenshotPath = _getEffectiveScreenshot(pageInfo);
                return screenshotPath != null && screenshotPath.isNotEmpty
                    ? ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                        ),
                        child: _buildScreenshot(screenshotPath),
                      )
                    : Container(
                        color: Colors.grey[800],
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_outlined,
                                color: Colors.grey[600],
                                size: 48,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'No screenshot available',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ],
      ],
    );
  }

  /// Returns screenshot path from page, or fallback from ApiData if page has none.
  String? _getEffectiveScreenshot(PageInfo page) {
    if (page.screenshot != null && page.screenshot!.isNotEmpty) {
      return page.screenshot;
    }
    final match = ApiData.getPages().where((p) => p.name == page.name).toList();
    return match.isNotEmpty ? match.first.screenshot : null;
  }

  Widget _buildScreenshot(String screenshotPath) {
    // Check if it's a URL (Firebase Storage) or local asset
    if (screenshotPath.startsWith('http://') || screenshotPath.startsWith('https://')) {
      // Firebase Storage URL
      return CachedNetworkImage(
        imageUrl: screenshotPath,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey[800],
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey[800],
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_not_supported,
                  color: Colors.grey[600],
                  size: 48,
                ),
                const SizedBox(height: 8),
                Text(
                  'Screenshot not found',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // Local asset
      return Image.asset(
        screenshotPath,
        width: double.infinity,
        height: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            color: Colors.grey[800],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.image_not_supported,
                    color: Colors.grey[600],
                    size: 48,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Screenshot not found',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    }
  }
}

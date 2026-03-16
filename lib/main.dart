import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'screens/api_dashboard.dart';
import 'screens/nahdi_man_screen.dart';
import 'screens/login_screen.dart';
import 'screens/developer_notes_screen.dart';
import 'screens/migration_screen.dart';
import 'screens_documentation/presentation/widgets/screen_details_widget.dart';
// Static data import commented out - using Firestore only
// import 'screens_documentation/data/screens_data.dart';
import 'screens_documentation/domain/models/screen_info_model.dart';
import 'providers/app_providers.dart';
import 'providers/firestore_providers.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // For web, Firebase requires explicit options
    if (kIsWeb) {
      // Check if firebase_options.dart has been configured
      if (DefaultFirebaseOptions.web.apiKey == 'YOUR_WEB_API_KEY') {
        print('⚠️  WARNING: Firebase web configuration not set up!');
        print('Please run: flutterfire configure');
        print('Or manually update lib/firebase_options.dart with your Firebase credentials');
        print('The app will continue but Firebase features will not work on web.');
      }
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    } else {
      // For mobile platforms, Firebase can auto-detect from config files
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
  } catch (e) {
    print('⚠️  Firebase initialization error: $e');
    print('The app will continue but Firebase features will not work.');
  }
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nahidi DEV Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0066CC),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isPagesExpanded = false;

  final List<Widget> _screens = [
    const ApiDashboard(),
    const NahdiManScreen(),
  ];

  final List<Map<String, dynamic>> _menuItems = [
    {
      'title': 'API Dashboard',
      'icon': Icons.dashboard,
      'index': 0,
    },
    {
      'title': 'Nahdi Man',
      'icon': Icons.api,
      'index': 1,
    },
  ];

  void _onMenuItemSelected(int index) {
    ref.read(currentScreenIndexProvider.notifier).state = index;
    _scaffoldKey.currentState?.closeDrawer();
  }

  void _onScreenDocumentationSelected(ScreenInfoModel screen) {
    _scaffoldKey.currentState?.closeDrawer();
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(screen.screenName),
          ),
          body: ScreenDetailsWidget(screen: screen),
        ),
      ),
    );
  }

  // Screens are now loaded directly in the Builder widget below
  // This getter is no longer needed - using ref.watch(screensProvider) directly

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currentIndex = ref.watch(currentScreenIndexProvider);

    return Scaffold(
      key: _scaffoldKey,
      body: _screens[currentIndex],
      drawer: Drawer(
        backgroundColor: theme.colorScheme.surface,
        child: Column(
          children: [
            // Drawer Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                border: Border(
                  bottom: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
              ),
              child: Stack(
                children: [
                  // Nahdi Icon in the background
                  Positioned(
                    right: 10,
                    top: 0,
                    bottom: 0,
                    child: Opacity(
                      opacity: 0.15,
                      child: SvgPicture.asset(
                        'assets/ic_nahdi.svg',
                        width: 120,
                        height: 120,
                      ),
                    ),
                  ),
                  // Title text in the foreground
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Nahidi DEV',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Dashboard',
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Menu Items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  // Regular menu items
                  ..._menuItems.map((item) {
                    final isSelected = currentIndex == item['index'];
                    return ListTile(
                      leading: Icon(
                        item['icon'] as IconData,
                        color: isSelected
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                      title: Text(
                        item['title'] as String,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      selected: isSelected,
                      selectedTileColor: theme.colorScheme.primary.withOpacity(0.1),
                      onTap: () => _onMenuItemSelected(item['index'] as int),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                    );
                  }),
                  
                  // Pages expandable section
                  ExpansionTile(
                    leading: Icon(
                      Icons.pages,
                      color: _isPagesExpanded
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withOpacity(0.7),
                    ),
                    title: Text(
                      'Pages',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: _isPagesExpanded ? FontWeight.bold : FontWeight.normal,
                        color: _isPagesExpanded
                            ? theme.colorScheme.primary
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    initiallyExpanded: _isPagesExpanded,
                    onExpansionChanged: (expanded) {
                      setState(() {
                        _isPagesExpanded = expanded;
                      });
                    },
                    children: [
                      // Developer Notes
                      ListTile(
                        leading: const SizedBox(width: 40),
                        title: Row(
                          children: [
                            Icon(
                              Icons.note,
                              size: 18,
                              color: theme.colorScheme.onSurface.withOpacity(0.8),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Developer Notes',
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.colorScheme.onSurface.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          _scaffoldKey.currentState?.closeDrawer();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const DeveloperNotesScreen(),
                            ),
                          );
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 4,
                        ),
                      ),
                      // Firebase Migration
                      ListTile(
                        leading: const SizedBox(width: 40),
                        title: Row(
                          children: [
                            Icon(
                              Icons.cloud_upload,
                              size: 18,
                              color: theme.colorScheme.onSurface.withOpacity(0.8),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Firebase Migration',
                              style: TextStyle(
                                fontSize: 14,
                                color: theme.colorScheme.onSurface.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                        onTap: () {
                          _scaffoldKey.currentState?.closeDrawer();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const MigrationScreen(),
                            ),
                          );
                        },
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 4,
                        ),
                      ),
                      // Divider
                      Divider(
                        height: 1,
                        thickness: 1,
                        color: theme.colorScheme.outline.withOpacity(0.2),
                        indent: 60,
                        endIndent: 20,
                      ),
                      // Documentation Screens
                      Builder(
                        builder: (context) {
                          // Watch screens provider - will auto-refresh when Firestore updates
                          final screensAsync = ref.watch(screensProvider);
                          
                          // Add refresh button when empty
                          return screensAsync.when(
                            data: (screens) {
                              print('📱 Sidebar: Received ${screens.length} screens from provider');
                              if (screens.isEmpty) {
                                return Column(
                                  children: [
                                    ListTile(
                                      leading: const SizedBox(width: 40),
                                      title: Row(
                                        children: [
                                          Icon(
                                            Icons.info_outline,
                                            size: 16,
                                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'No screens available',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                                                    fontStyle: FontStyle.italic,
                                                  ),
                                                ),
                                                const SizedBox(height: 4),
                                                Text(
                                                  'Run "Screens Only" migration',
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 20),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton.icon(
                                              onPressed: () {
                                                Navigator.of(context).pop(); // Close drawer
                                                Navigator.of(context).push(
                                                  MaterialPageRoute(
                                                    builder: (context) => const MigrationScreen(),
                                                  ),
                                                );
                                              },
                                              icon: const Icon(Icons.cloud_upload, size: 16),
                                              label: const Text('Go to Migration'),
                                              style: ElevatedButton.styleFrom(
                                                padding: const EdgeInsets.symmetric(
                                                  horizontal: 16,
                                                  vertical: 8,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          IconButton(
                                            onPressed: () {
                                              // Refresh screens provider
                                              ref.invalidate(screensProvider);
                                            },
                                            icon: const Icon(Icons.refresh),
                                            tooltip: 'Refresh screens',
                                            style: IconButton.styleFrom(
                                              backgroundColor: theme.colorScheme.primaryContainer,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              }
                              print('✅ Sidebar: Displaying ${screens.length} screens');
                              return Column(
                                children: screens.map((screen) {
                                  return ListTile(
                                    leading: const SizedBox(width: 40),
                                    title: Row(
                                      children: [
                                        Icon(
                                          Icons.description,
                                          size: 18,
                                          color: theme.colorScheme.onSurface.withOpacity(0.8),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            screen.screenName,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: theme.colorScheme.onSurface.withOpacity(0.8),
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                    onTap: () => _onScreenDocumentationSelected(screen),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 4,
                                    ),
                                  );
                                }).toList(),
                              );
                            },
                            loading: () {
                              print('⏳ Sidebar: Loading screens...');
                              return ListTile(
                                leading: const SizedBox(width: 40),
                                title: Row(
                                  children: [
                                    SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          theme.colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Loading screens...',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            error: (error, stackTrace) {
                              print('❌ Sidebar: Error loading screens: $error');
                              return ListTile(
                                leading: const SizedBox(width: 40),
                                title: Row(
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      size: 16,
                                      color: theme.colorScheme.error,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Error loading screens',
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: theme.colorScheme.error.withOpacity(0.8),
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'Check console for details',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: theme.colorScheme.error.withOpacity(0.6),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Drawer Footer
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outline.withOpacity(0.2),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: theme.colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Version 1.0.0',
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(_menuItems[currentIndex]['title'] as String),
            ),
            // Screenshot toggle button (only show on API Dashboard)
            if (currentIndex == 0)
              Builder(
                builder: (context) {
                  final showScreenshot = ref.watch(showScreenshotProvider);
                  return IconButton(
                    icon: Icon(
                      showScreenshot ? Icons.image : Icons.image_outlined,
                      size: 20,
                    ),
                    tooltip: showScreenshot ? 'Hide Screen Preview' : 'Show Screen Preview',
                    onPressed: () {
                      ref.read(showScreenshotProvider.notifier).state = !showScreenshot;
                    },
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  );
                },
              ),
          ],
        ),
        elevation: 0,
      ),
    );
  }
}

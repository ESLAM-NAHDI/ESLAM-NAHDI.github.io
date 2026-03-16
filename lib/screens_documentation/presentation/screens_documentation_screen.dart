import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Static data import commented out - using Firestore only
// import 'package:nahdi_api_dashboard/screens_documentation/data/screens_data.dart';
import 'package:nahdi_api_dashboard/screens_documentation/domain/models/screen_info_model.dart';
import 'package:nahdi_api_dashboard/screens_documentation/presentation/widgets/screen_details_widget.dart';
import 'package:nahdi_api_dashboard/providers/firestore_providers.dart';

class ScreensDocumentationScreen extends ConsumerStatefulWidget {
  final int? initialScreenIndex;
  
  const ScreensDocumentationScreen({super.key, this.initialScreenIndex});

  @override
  ConsumerState<ScreensDocumentationScreen> createState() => _ScreensDocumentationScreenState();
}

class _ScreensDocumentationScreenState extends ConsumerState<ScreensDocumentationScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  // Static data commented out - using Firestore only
  // final List<ScreenInfoModel> _screens = ScreensData.getAllScreens();
  
  List<ScreenInfoModel> get _screens {
    final screensAsync = ref.watch(screensProvider);
    return screensAsync.when(
      data: (screens) => screens,
      loading: () => <ScreenInfoModel>[],
      error: (_, __) => <ScreenInfoModel>[],
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _screens.length, 
      vsync: this,
      initialIndex: widget.initialScreenIndex ?? 0,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Screens Documentation'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: _screens.map((screen) => Tab(text: screen.screenName)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: _screens.map((screen) => ScreenDetailsWidget(screen: screen)).toList(),
      ),
    );
  }
}


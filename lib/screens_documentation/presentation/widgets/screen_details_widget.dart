import 'package:flutter/material.dart';
import 'package:nahdi_api_dashboard/screens_documentation/domain/models/screen_info_model.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ScreenDetailsWidget extends StatefulWidget {
  final ScreenInfoModel screen;

  const ScreenDetailsWidget({super.key, required this.screen});

  @override
  State<ScreenDetailsWidget> createState() => _ScreenDetailsWidgetState();
}

class _ScreenDetailsWidgetState extends State<ScreenDetailsWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _animationController.forward();
  }

  Widget _buildAnimatedSection({required Widget child, required int index}) {
    final delay = index * 0.1;
    final animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Interval(
          delay.clamp(0.0, 1.0),
          (delay + 0.3).clamp(0.0, 1.0),
          curve: Curves.easeOutCubic,
        ),
      ),
    );

    return FadeTransition(
      opacity: animation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Interval(
              delay.clamp(0.0, 1.0),
              (delay + 0.3).clamp(0.0, 1.0),
              curve: Curves.easeOutCubic,
            ),
          ),
        ),
        child: child,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left side - Content
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAnimatedSection(
                  index: 0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(context, 'Screen Information'),
                      _buildInfoCard([
                        _buildInfoRow('Screen Name', widget.screen.screenName),
                        _buildInfoRow('Route Name', widget.screen.routeName),
                        _buildInfoRow('File Path', widget.screen.filePath),
                        _buildInfoRow(
                          'State Management',
                          widget.screen.stateManagement,
                        ),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildAnimatedSection(
                  index: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(context, 'Description'),
                      _buildDescriptionCard(context, widget.screen.description),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildAnimatedSection(
                  index: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(context, 'Business Logic'),
                      _buildListCard(context, widget.screen.businessLogic),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildAnimatedSection(
                  index: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(context, 'Key Features'),
                      _buildListCard(context, widget.screen.keyFeatures),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildAnimatedSection(
                  index: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(context, 'Data Models'),
                      _buildSimpleListCard(context, widget.screen.dataModels),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildAnimatedSection(
                  index: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(context, 'Providers'),
                      _buildSimpleListCard(context, widget.screen.providers),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildAnimatedSection(
                  index: 6,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(context, 'Use Cases'),
                      _buildSimpleListCard(context, widget.screen.useCases),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildAnimatedSection(
                  index: 7,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(context, 'Child Screens'),
                      _buildSimpleListCard(context, widget.screen.childScreens),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildAnimatedSection(
                  index: 8,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle(context, 'API Endpoints'),
                      _buildApiEndpointsCard(
                        context,
                        widget.screen.apiEndpoints,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
        // Right side - Screenshot
        if (widget.screen.screenshot != null)
          Container(
            width: 400,
            decoration: const BoxDecoration(color: Colors.black),
            child: _buildScreenshot(widget.screen.screenshot!),
          ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }

  Widget _buildDescriptionCard(BuildContext context, String description) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(description, style: const TextStyle(fontSize: 14)),
      ),
    );
  }

  Widget _buildListCard(BuildContext context, List<String> items) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            items.length,
            (index) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 6, right: 8),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      items[index],
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleListCard(BuildContext context, List<String> items) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              items.map((item) {
                return Chip(
                  label: Text(item, style: const TextStyle(fontSize: 12)),
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildApiEndpointsCard(
    BuildContext context,
    Map<String, String> endpoints,
  ) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:
              endpoints.entries.map((entry) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 120,
                        child: Text(
                          '${entry.key}:',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          entry.value,
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: 'monospace',
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildScreenshot(String screenshotPath) {
    // Check if it's a URL (Firebase Storage) or local asset
    if (screenshotPath.startsWith('http://') || screenshotPath.startsWith('https://')) {
      // Firebase Storage URL
      return CachedNetworkImage(
        imageUrl: screenshotPath,
        width: double.infinity,
        fit: BoxFit.contain,
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
        fit: BoxFit.contain,
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

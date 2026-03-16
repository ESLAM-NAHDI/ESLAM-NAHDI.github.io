import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/api_info.dart';
import '../providers/app_providers.dart';
import 'nahdi_man_screen.dart';

class ApiDetailPage extends ConsumerStatefulWidget {
  final ApiInfo api;
  final String pageName;

  const ApiDetailPage({
    super.key,
    required this.api,
    required this.pageName,
  });

  @override
  ConsumerState<ApiDetailPage> createState() => _ApiDetailPageState();
}

class _ApiDetailPageState extends ConsumerState<ApiDetailPage> {

  Color _getMethodColor(String method) {
    switch (method.toUpperCase()) {
      case 'GET':
        return Colors.green;
      case 'POST':
        return Colors.blue;
      case 'PUT':
        return Colors.orange;
      case 'DELETE':
        return Colors.red;
      case 'PATCH':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }

  Future<void> _launchPostmanLink(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final methodColor = _getMethodColor(widget.api.method);
    final showNahdiMan = ref.watch(showNahdiManProvider);
    final leftPanelWidth = ref.watch(apiDetailLeftPanelWidthProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('API Details'),
        elevation: 0,
        actions: [
          // Toggle button to show/hide Nahdi Man
          IconButton(
            icon: Icon(
              showNahdiMan ? Icons.visibility_off : Icons.visibility,
              color: Colors.white,
            ),
            tooltip: showNahdiMan ? 'Hide Nahdi Man' : 'Show Nahdi Man',
            onPressed: () {
              ref.read(showNahdiManProvider.notifier).state = !showNahdiMan;
            },
          ),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Panel - API Details
          SizedBox(
            width: showNahdiMan ? leftPanelWidth : double.infinity,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Page Name Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: theme.colorScheme.primary.withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.dashboard,
                          size: 16,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          widget.pageName,
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Method Badge
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: methodColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.api.method,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.5),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.call_made,
                              size: 20,
                              color: Colors.blue[300],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${widget.api.numberOfCalls} calls',
                              style: TextStyle(
                                color: Colors.blue[300],
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 32),

                  // URL Section
                  _buildDetailSection(
                    context,
                    theme,
                    icon: Icons.link,
                    title: 'URL',
                    content: widget.api.url,
                    isCode: true,
                  ),

                  const SizedBox(height: 24),

                  // Description Section
                  _buildDetailSection(
                    context,
                    theme,
                    icon: Icons.description,
                    title: 'Description',
                    content: widget.api.description,
                    isCode: false,
                  ),

                  // Body Section (if exists)
                  if (widget.api.body != null && widget.api.body!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildDetailSection(
                      context,
                      theme,
                      icon: Icons.code,
                      title: 'Request Body',
                      content: widget.api.body!,
                      isCode: true,
                    ),
                  ],

                  // cURL Section (if exists)
                  if (widget.api.curl != null && widget.api.curl!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildDetailSection(
                      context,
                      theme,
                      icon: Icons.terminal,
                      title: 'cURL Command',
                      content: widget.api.curl!,
                      isCode: true,
                      showCopyButton: true,
                    ),
                  ],

                  // Postman Link Section
                  if (widget.api.postmanLink != null && widget.api.postmanLink!.isNotEmpty) ...[
                    const SizedBox(height: 32),
                    Card(
                      elevation: 2,
                      child: InkWell(
                        onTap: () => _launchPostmanLink(widget.api.postmanLink!),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Colors.orange.withOpacity(0.2),
                                Colors.orange.withOpacity(0.1),
                              ],
                            ),
                            border: Border.all(
                              color: Colors.orange.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.orange.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.open_in_new,
                                  color: Colors.orange[300],
                                  size: 24,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Postman Collection',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey[400],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Open in Postman',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.orange[300],
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Icon(
                                Icons.arrow_forward_ios,
                                size: 20,
                                color: Colors.orange[300],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // Right Panel - Nahdi Man (if visible)
          if (showNahdiMan) ...[
            // Draggable Divider
            MouseRegion(
              cursor: SystemMouseCursors.resizeColumn,
              child: GestureDetector(
                onPanUpdate: (details) {
                  final newWidth = leftPanelWidth + details.delta.dx;
                  // Constrain the width between 300 and screen width - 400
                  final screenWidth = MediaQuery.of(context).size.width;
                  ref.read(apiDetailLeftPanelWidthProvider.notifier).state = 
                      newWidth.clamp(300.0, screenWidth - 400.0);
                },
                child: Container(
                  width: 6,

                  decoration: BoxDecoration(
                    color: Colors.grey[800],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Container(
                      width: 2,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey[500],
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            // Nahdi Man Screen
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                child: NahdiManScreen(
                  initialCurl: widget.api.curl,
                  initialMethod: widget.api.method,
                  initialUrl: widget.api.url,
                  initialBody: widget.api.body,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailSection(
    BuildContext context,
    ThemeData theme, {
    required IconData icon,
    required String title,
    required String content,
    required bool isCode,
    bool showCopyButton = false,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                if (showCopyButton)
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: content));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Center(child: Text('cURL copied to clipboard', style: const TextStyle(color: Colors.white))),
                          duration: Duration(seconds: 2),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    tooltip: 'Copy to clipboard',
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (isCode)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Colors.grey[700]!,
                  ),
                ),
                child: SelectableText(
                  content,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: 'monospace',
                    color: Colors.white,
                  ),
                ),
              )
            else
              SelectableText(
                content,
                style: TextStyle(
                  fontSize: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.9),
                  height: 1.5,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

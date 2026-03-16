import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

final developerLinksProvider = StateNotifierProvider<DeveloperLinksNotifier, List<LinkItem>>((ref) {
  return DeveloperLinksNotifier();
});

class LinkItem {
  final String id;
  final String title;
  final String url;
  final DateTime createdAt;
  final String? createdBy;

  LinkItem({
    required this.id,
    required this.title,
    required this.url,
    required this.createdAt,
    this.createdBy,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'createdAt': createdAt.toIso8601String(),
      'createdBy': createdBy,
    };
  }

  factory LinkItem.fromJson(Map<String, dynamic> json) {
    return LinkItem(
      id: json['id'],
      title: json['title'],
      url: json['url'],
      createdAt: DateTime.parse(json['createdAt']),
      createdBy: json['createdBy'] as String?,
    );
  }
}

class DeveloperLinksNotifier extends StateNotifier<List<LinkItem>> {
  static const String _storageKey = 'developer_links';

  DeveloperLinksNotifier() : super([]) {
    _loadLinks();
  }

  Future<void> _loadLinks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final linksJson = prefs.getString(_storageKey);
      if (linksJson != null) {
        final List<dynamic> decoded = json.decode(linksJson);
        state = decoded.map((json) => LinkItem.fromJson(json)).toList();
      }
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> _saveLinks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final linksJson = json.encode(state.map((link) => link.toJson()).toList());
      await prefs.setString(_storageKey, linksJson);
    } catch (e) {
      // Handle error silently
    }
  }

  Future<void> addLink(String title, String url, {String? createdBy}) async {
    final link = LinkItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      url: url,
      createdAt: DateTime.now(),
      createdBy: createdBy,
    );
    state = [link, ...state];
    await _saveLinks();
  }

  Future<void> removeLink(String id) async {
    state = state.where((link) => link.id != id).toList();
    await _saveLinks();
  }

  Future<void> updateLink(String id, String title, String url) async {
    state = state.map((link) {
      if (link.id == id) {
        return LinkItem(
          id: link.id,
          title: title,
          url: url,
          createdAt: link.createdAt,
          createdBy: link.createdBy,
        );
      }
      return link;
    }).toList();
    await _saveLinks();
  }
}

class DeveloperLinksScreen extends ConsumerStatefulWidget {
  const DeveloperLinksScreen({super.key});

  @override
  ConsumerState<DeveloperLinksScreen> createState() => _DeveloperLinksScreenState();
}

class _DeveloperLinksScreenState extends ConsumerState<DeveloperLinksScreen> {
  @override
  Widget build(BuildContext context) {
    final links = ref.watch(developerLinksProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Links'),
      ),
      body: links.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.link_off,
                    size: 64,
                    color: theme.colorScheme.onSurface.withOpacity(0.3),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No links yet',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Tap the + button below to add your first link',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            )
          : Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 200,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1,
                ),
                itemCount: links.length,
                itemBuilder: (context, index) {
                  final link = links[index];
                  return _LinkSquare(
                    link: link,
                    onTap: () => _openUrl(link.url),
                    onEdit: () => _showLinkDialog(context, ref, existingLink: link),
                    onDelete: () => _confirmDelete(context, ref, link),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showLinkDialog(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showLinkDialog(BuildContext context, WidgetRef ref, {LinkItem? existingLink}) {
    final isEditing = existingLink != null;
    final titleController = TextEditingController(text: existingLink?.title ?? '');
    final urlController = TextEditingController(text: existingLink?.url ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Edit Link' : 'Add Link'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Link Title',
                  hintText: 'e.g. API Docs',
                  border: OutlineInputBorder(),
                ),
                autofocus: true,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: urlController,
                decoration: const InputDecoration(
                  labelText: 'Link URL',
                  hintText: 'https://...',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.url,
                autocorrect: false,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final title = titleController.text.trim();
              final url = urlController.text.trim();
              if (title.isNotEmpty && url.isNotEmpty) {
                if (!url.startsWith('http://') && !url.startsWith('https://')) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('URL must start with http:// or https://'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                  return;
                }
                if (isEditing) {
                  ref.read(developerLinksProvider.notifier).updateLink(existingLink.id, title, url);
                } else {
                  final createdBy = FirebaseAuth.instance.currentUser?.email;
                  ref.read(developerLinksProvider.notifier).addLink(title, url, createdBy: createdBy);
                }
                Navigator.of(context).pop();
              }
            },
            child: Text(isEditing ? 'Update' : 'Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null) {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, LinkItem link) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Link'),
        content: Text('Are you sure you want to remove "${link.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(developerLinksProvider.notifier).removeLink(link.id);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

class _LinkSquare extends StatelessWidget {
  final LinkItem link;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _LinkSquare({
    required this.link,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        onLongPress: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: const Icon(Icons.open_in_new),
                    title: const Text('Open Link'),
                    onTap: () {
                      Navigator.pop(context);
                      onTap();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.edit),
                    title: const Text('Edit'),
                    onTap: () {
                      Navigator.pop(context);
                      onEdit();
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.delete, color: Colors.red),
                    title: const Text('Delete', style: TextStyle(color: Colors.red)),
                    onTap: () {
                      Navigator.pop(context);
                      onDelete();
                    },
                  ),
                ],
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: Text(
                              link.title,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: theme.colorScheme.onSurface,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (link.createdBy != null && link.createdBy!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        'Created by ${link.createdBy}',
                        style: TextStyle(
                          fontSize: 11,
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  else
                    const SizedBox.shrink(),
                ],
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, size: 18),
                    onPressed: onEdit,
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(4),
                      minimumSize: const Size(32, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, size: 18, color: Colors.red.shade700),
                    onPressed: () {
                      onDelete();
                    },
                    style: IconButton.styleFrom(
                      padding: const EdgeInsets.all(4),
                      minimumSize: const Size(32, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

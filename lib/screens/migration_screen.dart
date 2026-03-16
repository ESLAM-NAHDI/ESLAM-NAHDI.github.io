import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/firestore_migration_helper.dart';
import '../providers/firestore_providers.dart';

class MigrationScreen extends ConsumerStatefulWidget {
  const MigrationScreen({super.key});

  @override
  ConsumerState<MigrationScreen> createState() => _MigrationScreenState();
}

class _MigrationScreenState extends ConsumerState<MigrationScreen> {
  final FirestoreMigrationHelper _migrationHelper = FirestoreMigrationHelper();
  bool _isMigrating = false;
  String _status = 'Ready to migrate';
  List<String> _logs = [];

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)} - $message');
    });
  }

  Future<void> _migrateAll() async {
    setState(() {
      _isMigrating = true;
      _status = 'Migrating...';
      _logs.clear();
    });

    _addLog('Starting migration to Firebase...');

    try {
      await _migrationHelper.migrateAll();
      setState(() {
        _status = 'Migration completed successfully!';
        _isMigrating = false;
      });
      _addLog('✅ Migration completed successfully!');
      
      // Refresh providers so UI updates automatically
      ref.invalidate(screensProvider);
      ref.invalidate(pagesProvider);
      _addLog('🔄 Refreshing data...');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Center(child: Text('Migration completed! Data will refresh automatically.', style: const TextStyle(color: Colors.white))),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _status = 'Migration failed';
        _isMigrating = false;
      });
      _addLog('❌ Migration failed: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(child: Text('Migration failed: $e', style: const TextStyle(color: Colors.white))),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _migrateScreensOnly() async {
    setState(() {
      _isMigrating = true;
      _status = 'Migrating screens...';
      _logs.clear();
    });

    _addLog('Starting screens migration...');

    try {
      await _migrationHelper.migrateScreens();
      setState(() {
        _status = 'Screens migration completed!';
        _isMigrating = false;
      });
      _addLog('✅ Screens migration completed!');
      
      // Refresh screens provider so sidebar updates automatically
      ref.invalidate(screensProvider);
      _addLog('🔄 Refreshing screens list...');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Center(child: Text('Screens migrated successfully! Sidebar will update automatically.', style: const TextStyle(color: Colors.white))),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _status = 'Screens migration failed';
        _isMigrating = false;
      });
      _addLog('❌ Screens migration failed: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(child: Text('Migration failed: $e', style: const TextStyle(color: Colors.white))),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _migratePagesOnly() async {
    setState(() {
      _isMigrating = true;
      _status = 'Migrating pages...';
      _logs.clear();
    });

    _addLog('Starting pages migration...');

    try {
      await _migrationHelper.migratePages();
      setState(() {
        _status = 'Pages migration completed!';
        _isMigrating = false;
      });
      _addLog('✅ Pages migration completed!');
      
      // Refresh pages provider so dropdown updates automatically
      ref.invalidate(pagesProvider);
      _addLog('🔄 Refreshing pages list...');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Center(child: Text('Pages migrated successfully! Dropdown will update automatically.', style: const TextStyle(color: Colors.white))),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _status = 'Pages migration failed';
        _isMigrating = false;
      });
      _addLog('❌ Pages migration failed: $e');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Center(child: Text('Migration failed: $e', style: const TextStyle(color: Colors.white))),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Migration'),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.cloud_upload,
                          color: theme.colorScheme.primary,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Firebase Migration',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'This will migrate all static data to Firebase:',
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildMigrationItem('📱 Screens', 'Screen documentation data'),
                    _buildMigrationItem('📄 Pages', 'API pages with cURL commands'),
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(top: 8),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, size: 16, color: Colors.orange[700]),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Images will use local assets (not uploaded)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primaryContainer.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.lightbulb_outline,
                                size: 16,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Important:',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '• "Migrate All" migrates both screens AND pages\n'
                            '• "Screens Only" migrates documentation screens\n'
                            '• "Pages Only" migrates API pages\n\n'
                            'If screens are missing, run "Screens Only" migration.',
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurface.withOpacity(0.8),
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isMigrating ? null : _migrateAll,
                    icon: const Icon(Icons.cloud_upload),
                    label: const Text('Migrate All'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isMigrating ? null : _migrateScreensOnly,
                    icon: const Icon(Icons.phone_android),
                    label: const Text('Screens Only'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isMigrating ? null : _migratePagesOnly,
                    icon: const Icon(Icons.description),
                    label: const Text('Pages Only'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isMigrating ? Icons.sync : Icons.info_outline,
                          color: _isMigrating 
                              ? theme.colorScheme.primary 
                              : theme.colorScheme.onSurface.withOpacity(0.7),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _status,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _isMigrating 
                                ? theme.colorScheme.primary 
                                : theme.colorScheme.onSurface,
                          ),
                        ),
                        if (_isMigrating) ...[
                          const SizedBox(width: 12),
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
                        ],
                      ],
                    ),
                    if (_logs.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Container(
                        height: 300,
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(12),
                          itemCount: _logs.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                _logs[index],
                                style: const TextStyle(
                                  color: Colors.greenAccent,
                                  fontSize: 12,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMigrationItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


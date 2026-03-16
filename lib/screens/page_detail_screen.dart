import 'package:flutter/material.dart';

class PageDetailScreen extends StatelessWidget {
  final String pageName;

  const PageDetailScreen({
    super.key,
    required this.pageName,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Details'),
        elevation: 0,
      ),
      body: Center(
        child: Text(
          pageName,
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}





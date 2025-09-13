import 'package:flutter/material.dart';

class ContentUnavailableView extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onRetry;

  const ContentUnavailableView.name({
    super.key,
    required this.title,
    required this.description,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 16,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          Text(description),
          ElevatedButton(onPressed: onRetry, child: const Text("Reload")),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:sketra/models/Wallpaper.dart';

class FeedPageGridCell extends StatelessWidget {
  final Wallpaper wallpaper;
  final VoidCallback onTap;

  const FeedPageGridCell({
    super.key,
    required this.wallpaper,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            wallpaper.url,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, event) {
              if (event == null) {
                return child;
              } else {
                return Center(
                  child: CircularProgressIndicator(
                    value: event.expectedTotalBytes != null
                        ? event.cumulativeBytesLoaded /
                              event.expectedTotalBytes!
                        : null,
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }
}

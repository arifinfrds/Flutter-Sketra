import 'package:flutter/material.dart';
import 'package:sketra/models/Wallpaper.dart';

import '../shared/AsyncImage.dart';

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
          child: AsyncImage(url: wallpaper.url),
        ),
      ),
    );
  }
}

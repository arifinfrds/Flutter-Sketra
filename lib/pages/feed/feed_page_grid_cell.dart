import 'package:flutter/material.dart';
import 'package:sketra/data/domain/wallpaper_entity.dart';

import '../shared/async_image.dart';

class FeedPageGridCell extends StatelessWidget {
  final WallpaperEntity wallpaper;
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
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: EdgeInsetsGeometry.fromLTRB(0, 0, 0, 4),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(child: AsyncImage(url: wallpaper.url)),
                  const SizedBox(height: 8),
                  _footerView(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _footerView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              wallpaper.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          IconButton(onPressed: () {}, icon: Icon(Icons.favorite)),
        ],
      ),
    );
  }
}

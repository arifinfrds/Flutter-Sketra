import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/domain/wallpaper_entity.dart';
import '../shared/async_image.dart';
import 'feed_view_model.dart';

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
    final vm = context.watch<FeedViewModel>();

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Material(
        color: Colors.transparent,
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: AsyncImage(url: wallpaper.url)),
                const SizedBox(height: 8),
                _footerView(context, vm),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _footerView(BuildContext context, FeedViewModel viewModel) {
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
          IconButton(
            onPressed: () => viewModel.toggleFavorite(wallpaper),
            icon: Icon(
              viewModel.isFavorite(wallpaper)
                  ? Icons.favorite
                  : Icons.favorite_border,
            ),
          ),
        ],
      ),
    );
  }
}

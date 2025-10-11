import 'package:sketra/pages/favorites/favorites_view_model.dart';

import '../../data/domain/wallpaper_entity.dart';
import '../detail/feed_detail_view_model.dart';

final class FavoritesPageToggleAdapter implements FeedDetailViewModelDelegate {
  FavoritesViewModel viewModel;

  FavoritesPageToggleAdapter(this.viewModel);

  @override
  Future<void> didToggleFavorite(WallpaperEntity wallpaper) async {
    await viewModel.toggleFavorite(wallpaper);
  }
}

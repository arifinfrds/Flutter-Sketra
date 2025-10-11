import '../../data/domain/wallpaper_entity.dart';
import '../detail/feed_detail_view_model.dart';
import 'feed_view_model.dart';

final class FeedPageToggleAdapter implements FeedDetailViewModelDelegate {
  final FeedViewModel _feedViewModel;

  FeedPageToggleAdapter(this._feedViewModel);

  @override
  Future<void> didToggleFavorite(WallpaperEntity wallpaper) async {
    await _feedViewModel.toggleFavorite(wallpaper);
  }
}

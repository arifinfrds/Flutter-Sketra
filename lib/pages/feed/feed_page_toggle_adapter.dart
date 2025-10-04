import '../../data/domain/wallpaper_entity.dart';
import '../detail/feed_detail_view_model.dart';
import 'feed_view_model.dart';

final class FeedPageToggleAdapter implements FeedDetailViewModelDelegate {
  final FeedViewModel _feedViewModel;

  FeedPageToggleAdapter(this._feedViewModel);

  @override
  void didToggleFavorite(WallpaperEntity wallpaper) {
    _feedViewModel.toggleFavorite(wallpaper);
  }
}

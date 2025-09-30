import 'package:flutter/foundation.dart';
import 'package:sketra/data/domain/check_is_favorite_wallpaper_use_case.dart';
import 'package:sketra/data/domain/wallpaper_entity.dart';

import '../../data/networking/json_wallpaper_service.dart';

enum FeedViewState {
  initial,
  loading,
  empty,
  loaded,
  error,
  pullToRefreshLoading,
}

enum FeedViewLoadType { normal, pullToRefresh }

class FeedViewModel extends ChangeNotifier {
  final JsonWallpaperService wallpaperService;
  final CheckIsFavoriteWallpaperUseCase checkIsFavoriteWallpaperUseCase;

  List<WallpaperEntity> wallpapers = [];
  FeedViewState viewState = FeedViewState.initial;
  String errorMessage = "";

  final Set<String> _favoriteIds = {};

  FeedViewModel({
    required this.wallpaperService,
    required this.checkIsFavoriteWallpaperUseCase,
  });

  Future<void> onLoad() async {
    _loadWallpapers(FeedViewLoadType.normal);
  }

  void _loadWallpapers(FeedViewLoadType loadType) async {
    viewState = loadType == FeedViewLoadType.normal
        ? FeedViewState.loading
        : FeedViewState.pullToRefreshLoading;
    notifyListeners();

    try {
      await Future.delayed(const Duration(seconds: 2));
      wallpapers = await wallpaperService.loadWallpapers();

      viewState = wallpapers.isEmpty
          ? FeedViewState.empty
          : FeedViewState.loaded;

      _setFavoriteIdsFor(wallpapers);
    } catch (exception) {
      errorMessage = exception.toString();
      viewState = FeedViewState.error;
    }
    notifyListeners();
  }

  Future<void> _setFavoriteIdsFor(List<WallpaperEntity> wallpapers) async {
    for (var wallpaper in wallpapers) {
      final isFavorite = await checkIsFavoriteWallpaperUseCase.execute(
        wallpaper,
      );
      if (isFavorite) {
        _favoriteIds.add(wallpaper.id);
      }
    }
  }

  Future<void> onPullToRefresh() async {
    _loadWallpapers(FeedViewLoadType.pullToRefresh);
  }

  bool isFavorite(WallpaperEntity wallpaper) {
    return _favoriteIds.contains(wallpaper.id);
  }

  void toggleFavorite(WallpaperEntity wallpaper) {
    if (isFavorite(wallpaper)) {
      _favoriteIds.remove(wallpaper.id);
    } else {
      _favoriteIds.add(wallpaper.id);
    }
    notifyListeners();
  }
}

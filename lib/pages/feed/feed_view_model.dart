import 'package:flutter/foundation.dart';
import 'package:sketra/data/domain/check_is_favorite_wallpaper_use_case.dart';
import 'package:sketra/data/domain/wallpaper_entity.dart';

import '../../data/domain/favorite_wallpaper_use_case.dart';
import '../../data/domain/unfavorite_wallpaper_use_case.dart';
import '../../data/networking/json_wallpaper_service.dart';

enum FeedViewState {
  initial,
  loading,
  empty,
  loaded,
  error,
  pullToRefreshLoading,
  favoriteUnfavoriteOperationError,
}

enum FeedViewLoadType { normal, pullToRefresh }

typedef ViewState = FeedViewState;

class FeedViewModel extends ChangeNotifier {
  final JsonWallpaperService wallpaperService;
  final CheckIsFavoriteWallpaperUseCase checkIsFavoriteWallpaperUseCase;
  final FavoriteWallpaperUseCase favoriteWallpaperUseCase;
  final UnFavoriteWallpaperUseCase unfavoriteWallpaperUseCase;

  List<WallpaperEntity> wallpapers = [];
  FeedViewState viewState = FeedViewState.initial;
  String errorMessage = "";

  final Set<String> _favoriteIds = {};

  FeedViewModel({
    required this.wallpaperService,
    required this.checkIsFavoriteWallpaperUseCase,
    required this.favoriteWallpaperUseCase,
    required this.unfavoriteWallpaperUseCase,
  });

  Future<void> onLoad() async {
    _loadWallpapers(FeedViewLoadType.normal);
  }

  void _loadWallpapers(FeedViewLoadType loadType) async {
    viewState = loadType == FeedViewLoadType.normal
        ? ViewState.loading
        : ViewState.pullToRefreshLoading;
    notifyListeners();

    try {
      var receivedWallpapers = await wallpaperService.loadWallpapers();
      this.wallpapers = receivedWallpapers;

      viewState = wallpapers.isEmpty ? ViewState.empty : ViewState.loaded;

      _setFavoriteIdsFor(wallpapers);
    } catch (exception) {
      errorMessage = exception.toString();
      viewState = ViewState.error;
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

  Future<void> toggleFavorite(WallpaperEntity wallpaper) async {
    if (isFavorite(wallpaper)) {
      _favoriteIds.remove(wallpaper.id);
    } else {
      _favoriteIds.add(wallpaper.id);
    }
    notifyListeners();

    if (isFavorite(wallpaper)) {
      await _setWallpaperAsFavorite(wallpaper);
    } else {
      await _removeWallpaperFromFavorite(wallpaper);
    }
    notifyListeners();
  }

  Future<void> _setWallpaperAsFavorite(WallpaperEntity wallpaper) async {
    try {
      await favoriteWallpaperUseCase.execute(wallpaper);
    } catch (e) {
      errorMessage = "Something went wrong, please try again later.";
      viewState = ViewState.favoriteUnfavoriteOperationError;
    }
  }

  Future<void> _removeWallpaperFromFavorite(WallpaperEntity wallpaper) async {
    try {
      unfavoriteWallpaperUseCase.execute(wallpaper);
    } catch (e) {
      errorMessage = "Something went wrong, please try again later.";
      viewState = ViewState.favoriteUnfavoriteOperationError;
    }
  }
}

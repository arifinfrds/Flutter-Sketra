import 'package:flutter/foundation.dart';
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
  final JsonWallpaperService _wallpaperService;

  List<WallpaperEntity> wallpapers = [];
  FeedViewState viewState = FeedViewState.initial;
  String errorMessage = "";

  FeedViewModel(this._wallpaperService);

  Future<void> onLoad() async {
    loadWallpapers(FeedViewLoadType.normal);
  }

  void loadWallpapers(FeedViewLoadType loadType) async {
    viewState = loadType == FeedViewLoadType.normal
        ? FeedViewState.loading
        : FeedViewState.pullToRefreshLoading;
    notifyListeners();
    try {
      await Future.delayed(const Duration(seconds: 2));
      wallpapers = await _wallpaperService.loadWallpapers();

      viewState = wallpapers.isEmpty
          ? FeedViewState.empty
          : FeedViewState.loaded;
    } catch (exception) {
      errorMessage = exception.toString();
      viewState = FeedViewState.error;
    }
    notifyListeners();
  }

  Future<void> onPullToRefresh() async {
    loadWallpapers(FeedViewLoadType.pullToRefresh);
  }
}

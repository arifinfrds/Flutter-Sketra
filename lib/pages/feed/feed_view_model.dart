import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sketra/models/mock_wallpaper_service.dart';
import 'package:sketra/models/wallpaper.dart';
import 'package:sketra/models/wallpaper_response.dart';

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
  List<Wallpaper> wallpapers = [];
  FeedViewState viewState = FeedViewState.initial;
  String errorMessage = "";

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
      final jsonString = await rootBundle.loadString('assets/mock_feed.json');
      MockWallpaperService repository = MockWallpaperService.name(jsonString);
      WallpaperResponse response = await repository.loadWallpapers();

      wallpapers = response.wallpapers;
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

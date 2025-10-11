import 'package:flutter/widgets.dart';
import 'package:sketra/data/domain/load_favorite_wallpapers_use_case.dart';
import 'package:sketra/data/domain/unfavorite_wallpaper_use_case.dart';
import 'package:sketra/data/domain/wallpaper_entity.dart';

enum FavoritesViewModelViewState {
  initial,
  loading,
  loaded,
  error,
  empty,
  pullToRefreshLoading,
  favoriteUnfavoriteOperationError,
}

typedef ViewState = FavoritesViewModelViewState;

final class FavoritesViewModel extends ChangeNotifier {
  final LoadFavoriteWallpapersUseCase loadFavoriteWallpapersUseCase;
  final UnFavoriteWallpaperUseCase unfavoriteWallpaperUseCase;

  FavoritesViewModel({
    required this.loadFavoriteWallpapersUseCase,
    required this.unfavoriteWallpaperUseCase,
  });

  ViewState _viewState = ViewState.initial;

  ViewState get viewState => _viewState;

  List<WallpaperEntity> _wallpapers = [];

  List<WallpaperEntity> get wallpapers => _wallpapers;

  String _errorMessage = "";

  String get errorMessage => _errorMessage;

  Future<void> onLoad() async {
    _viewState = ViewState.loading;
    notifyListeners();

    try {
      _wallpapers = await loadFavoriteWallpapersUseCase.execute();
      _viewState = _wallpapers.isEmpty ? ViewState.empty : ViewState.loaded;
    } catch (e) {
      _errorMessage = e.toString();
      _viewState = ViewState.error;
    }
    notifyListeners();
  }

  Future<void> onReload() async {
    await onLoad();
  }

  Future<void> toggleFavorite(WallpaperEntity wallpaper) async {
    await _removeWallpaperFromFavorite(wallpaper);
  }

  Future<void> _removeWallpaperFromFavorite(WallpaperEntity wallpaper) async {
    try {
      await unfavoriteWallpaperUseCase.execute(wallpaper);
      _wallpapers.removeWhere((w) => w.id == wallpaper.id);
      _viewState = _wallpapers.isEmpty ? ViewState.empty : ViewState.loaded;
      notifyListeners();
    } catch (e) {
      _errorMessage = "Something went wrong, please try again later.";
      _viewState = ViewState.favoriteUnfavoriteOperationError;
    }
    notifyListeners();
  }
}

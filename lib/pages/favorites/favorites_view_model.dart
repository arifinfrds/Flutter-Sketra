import 'package:flutter/widgets.dart';
import 'package:sketra/data/domain/load_favorite_wallpapers_use_case.dart';
import 'package:sketra/data/domain/wallpaper_entity.dart';

enum FavoritesViewModelViewState { initial, loading, loaded, error, empty }

typedef ViewState = FavoritesViewModelViewState;

final class FavoritesViewModel extends ChangeNotifier {
  final LoadFavoriteWallpapersUseCase loadFavoriteWallpapersUseCase;

  FavoritesViewModel({required this.loadFavoriteWallpapersUseCase});

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
}


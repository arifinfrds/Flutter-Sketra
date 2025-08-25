import 'package:flutter/foundation.dart';
import 'package:sketra/models/wallpaper.dart';

import '../../models/mock_wallpaper_service.dart';

enum FeedDetailViewModelViewState { initial, loading, loaded, error }

class FeedDetailViewModel extends ChangeNotifier {
  final String _wallpaperId;
  final MockWallpaperService _repository;

  Wallpaper? _wallpaper;
  FeedDetailViewModelViewState _viewState =
      FeedDetailViewModelViewState.initial;

  Wallpaper? get wallpaper => _wallpaper;

  FeedDetailViewModelViewState get viewState => _viewState;

  String _errorMessage = "";

  String get errorMessage => _errorMessage;

  FeedDetailViewModel(this._wallpaperId, this._repository);

  Future<void> onLoad() async {
    _viewState = FeedDetailViewModelViewState.loading;
    notifyListeners();

    try {
      _wallpaper = await _repository.loadWallpaper(_wallpaperId);
      _viewState = FeedDetailViewModelViewState.loaded;
    } catch (exception) {
      _errorMessage = exception.toString();
      _viewState = FeedDetailViewModelViewState.error;
    }
    notifyListeners();
  }

  String pageTitle() {
    return wallpaper?.title ?? 'Detail page';
  }
}

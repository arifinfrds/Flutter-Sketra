import 'package:flutter/foundation.dart';
import 'package:sketra/models/Wallpaper.dart';

import '../../models/MockWallpaperRepository.dart';

enum FeedDetailViewModelViewState { initial, loading, loaded, error }

class FeedDetailViewModel extends ChangeNotifier {
  final String _wallpaperId;
  final MockWallpaperRepository _repository;

  Wallpaper? _wallpaper;
  Wallpaper? get wallpaper => _wallpaper;

  FeedDetailViewModelViewState _viewState = FeedDetailViewModelViewState.initial;
  FeedDetailViewModelViewState get viewState => _viewState;

  FeedDetailViewModel(this._wallpaperId, this._repository);

  Future<void> onLoad() async {
    _viewState = FeedDetailViewModelViewState.loading;
    notifyListeners();

    try {
      _wallpaper = await _repository.loadWallpaper(_wallpaperId);
      _viewState = FeedDetailViewModelViewState.loaded;
    } catch (e) {
      _viewState = FeedDetailViewModelViewState.error;
    }
    notifyListeners();
  }
}

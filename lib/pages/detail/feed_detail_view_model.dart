import 'package:flutter/foundation.dart';
import 'package:sketra/models/download_wallpaper_service.dart';
import 'package:sketra/models/wallpaper.dart';

import '../../models/mock_wallpaper_service.dart';

enum FeedDetailViewModelViewState {
  initial,
  loading,
  loaded,
  error,
  imageDownloadedToDevice,
  imageDownloadedToDeviceError,
}

class FeedDetailViewModel extends ChangeNotifier {
  final String _wallpaperId;
  final MockWallpaperService _wallpaperService;
  final DownloadWallpaperService _downloadWallpaperService;

  Wallpaper? _wallpaper;
  FeedDetailViewModelViewState _viewState =
      FeedDetailViewModelViewState.initial;

  Wallpaper? get wallpaper => _wallpaper;

  FeedDetailViewModelViewState get viewState => _viewState;

  String _errorMessage = "";

  String get errorMessage => _errorMessage;

  FeedDetailViewModel(
    this._wallpaperId,
    this._wallpaperService,
    this._downloadWallpaperService,
  );

  Future<void> onLoad() async {
    _viewState = FeedDetailViewModelViewState.loading;
    notifyListeners();

    try {
      _wallpaper = await _wallpaperService.loadWallpaper(_wallpaperId);
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

  Future<void> onDownloadWallpaper() async {
    _viewState = FeedDetailViewModelViewState.loading;
    notifyListeners();
    try {
      _downloadWallpaperService.downloadImage(_wallpaper!.url);
      _viewState = FeedDetailViewModelViewState.imageDownloadedToDevice;
    } catch (exception) {
      _errorMessage = exception.toString();
      _viewState = FeedDetailViewModelViewState.imageDownloadedToDeviceError;
    }
    notifyListeners();
  }

  void resetDownloadState() {
    if (_viewState == FeedDetailViewModelViewState.imageDownloadedToDevice ||
        _viewState ==
            FeedDetailViewModelViewState.imageDownloadedToDeviceError) {
      _viewState = FeedDetailViewModelViewState.loaded;
      notifyListeners();
    }
  }
}

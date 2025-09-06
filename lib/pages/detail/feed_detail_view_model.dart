import 'package:flutter/foundation.dart';
import 'package:sketra/models/download_wallpaper_service.dart';
import 'package:sketra/models/wallpaper.dart';
import '../../models/mock_wallpaper_service.dart';

enum FeedDetailViewModelViewState {
  initial,
  loading,
  loaded,
  error,
  imageDownloadLoadingStarted,
  imageDownloadedToDevice,
  imageDownloadedToDeviceError,
  settingImageAsWallpaperSuccessfully,
  settingImageAsWallpaperError,
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
    _viewState = FeedDetailViewModelViewState.imageDownloadLoadingStarted;
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
    switch (_viewState) {
      case FeedDetailViewModelViewState.imageDownloadedToDevice ||
          FeedDetailViewModelViewState.imageDownloadedToDeviceError ||
          FeedDetailViewModelViewState.settingImageAsWallpaperSuccessfully ||
          FeedDetailViewModelViewState.settingImageAsWallpaperError:
        notifyListeners();
        break;
      default:
        break;
    }
  }

  void setAsWallpaper() async {
    _viewState = FeedDetailViewModelViewState.imageDownloadLoadingStarted;
    notifyListeners();
    try {
      final url = _wallpaper!.url;
      await _downloadWallpaperService.setImageAsSystemWallpaper(url);
      _viewState = FeedDetailViewModelViewState.imageDownloadedToDevice;
      _viewState =
          FeedDetailViewModelViewState.settingImageAsWallpaperSuccessfully;
    } catch (exception) {
      _errorMessage = exception.toString();
      _viewState = FeedDetailViewModelViewState.settingImageAsWallpaperError;
    }
    notifyListeners();
  }

  String? getToastMessage() {
    String? message;

    switch (viewState) {
      case FeedDetailViewModelViewState.imageDownloadLoadingStarted:
        message = "Downloading image...";
        break;
      case FeedDetailViewModelViewState.imageDownloadedToDevice:
        message = "Image has been downloaded to your device gallery app";
        break;
      case FeedDetailViewModelViewState.imageDownloadedToDeviceError:
        message =
            "Could not download the image to your device gallery. Please check your permission in system settings, or try again later.";
        break;
      case FeedDetailViewModelViewState.settingImageAsWallpaperSuccessfully:
        message = "Wallpaper set successfully!";
        break;
      case FeedDetailViewModelViewState.settingImageAsWallpaperError:
        message = "Failed to set wallpaper. Please try again.";
        break;
      default:
        break;
    }

    return message;
  }
}

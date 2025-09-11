import 'package:flutter/foundation.dart';
import 'package:sketra/models/download_wallpaper_service.dart';
import 'package:sketra/models/wallpaper.dart';
import '../../models/mock_wallpaper_service.dart';
import '../../models/set_wallpaper_type.dart';

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

typedef ViewState = FeedDetailViewModelViewState;

class FeedDetailViewModel extends ChangeNotifier {
  final String _wallpaperId;
  final MockWallpaperService _wallpaperService;
  final DownloadWallpaperService _downloadWallpaperService;

  Wallpaper? _wallpaper;
  ViewState _viewState = ViewState.initial;

  Wallpaper? get wallpaper => _wallpaper;

  ViewState get viewState => _viewState;

  String _errorMessage = "";

  String get errorMessage => _errorMessage;

  FeedDetailViewModel(
    this._wallpaperId,
    this._wallpaperService,
    this._downloadWallpaperService,
  );

  Future<void> onLoad() async {
    _viewState = ViewState.loading;
    notifyListeners();

    try {
      _wallpaper = await _wallpaperService.loadWallpaper(_wallpaperId);
      _viewState = ViewState.loaded;
    } catch (exception) {
      _errorMessage = exception.toString();
      _viewState = ViewState.error;
    }
    notifyListeners();
  }

  String pageTitle() {
    return wallpaper?.title ?? 'Detail page';
  }

  Future<void> onDownloadWallpaper() async {
    _viewState = ViewState.imageDownloadLoadingStarted;
    notifyListeners();
    try {
      _downloadWallpaperService.downloadImage(_wallpaper!.url);
      _viewState = ViewState.imageDownloadedToDevice;
    } catch (exception) {
      _errorMessage = exception.toString();
      _viewState = ViewState.imageDownloadedToDeviceError;
    }
    notifyListeners();
  }

  void setAsWallpaper(SetWallpaperType setWallpaperType) async {
    _viewState = ViewState.imageDownloadLoadingStarted;
    notifyListeners();
    try {
      final url = _wallpaper!.url;
      await _downloadWallpaperService.setImageAsSystemWallpaper(
        url,
        setWallpaperType,
      );
      _viewState = ViewState.settingImageAsWallpaperSuccessfully;
    } catch (exception) {
      _errorMessage = exception.toString();
      _viewState = ViewState.settingImageAsWallpaperError;
    }
    notifyListeners();
  }

  String? getToastMessage() {
    String? message;

    switch (viewState) {
      case ViewState.imageDownloadLoadingStarted:
        message = "Downloading image...";
        break;
      case ViewState.imageDownloadedToDevice:
        message = "Image has been downloaded to your device gallery app";
        break;
      case ViewState.imageDownloadedToDeviceError:
        message =
            "Could not download the image to your device gallery. Please check your permission in system settings, or try again later.";
        break;
      case ViewState.settingImageAsWallpaperSuccessfully:
        message = "Wallpaper set successfully!";
        break;
      case ViewState.settingImageAsWallpaperError:
        message = "Failed to set wallpaper. Please try again.";
        break;
      default:
        break;
    }

    return message;
  }
}

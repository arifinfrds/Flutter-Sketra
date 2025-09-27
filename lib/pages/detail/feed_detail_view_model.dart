import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:sketra/data/domain/check_is_favorite_wallpaper_use_case.dart';
import 'package:sketra/data/domain/unfavorite_wallpaper_use_case.dart';
import 'package:sketra/data/domain/wallpaper_entity.dart';

import '../../data/domain/favorite_wallpaper_use_case.dart';
import '../../data/networking/download_wallpaper_service.dart';
import '../../data/networking/json_wallpaper_service.dart';
import '../../data/networking/set_wallpaper_type.dart';

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
  favoriteUnfavoriteOperationError,
  favoriteActionLoading,
  favoriteActionLoadingFinished,
}

typedef ViewState = FeedDetailViewModelViewState;

class FeedDetailViewModel extends ChangeNotifier {
  final String _wallpaperId;
  final JsonWallpaperService _wallpaperService;
  final DownloadWallpaperService _downloadWallpaperService;
  final CheckIsFavoriteWallpaperUseCase _checkIsFavoriteWallpaperUseCase;
  final FavoriteWallpaperUseCase _favoriteWallpaperUseCase;
  final UnFavoriteWallpaperUseCase _unfavoriteWallpaperUseCase;

  WallpaperEntity? _wallpaper;
  ViewState _viewState = ViewState.initial;

  WallpaperEntity? get wallpaper => _wallpaper;

  ViewState get viewState => _viewState;

  String _errorMessage = "";

  String get errorMessage => _errorMessage;

  bool _isFavorite = false;

  bool get isFavorite => _isFavorite;

  FeedDetailViewModel(
    this._wallpaperId,
    this._wallpaperService,
    this._downloadWallpaperService,
    this._checkIsFavoriteWallpaperUseCase,
    this._favoriteWallpaperUseCase,
    this._unfavoriteWallpaperUseCase,
  );

  Future<void> onLoad() async {
    _viewState = ViewState.loading;
    notifyListeners();

    try {
      _wallpaper = await _wallpaperService.loadWallpaper(_wallpaperId);
      _viewState = ViewState.loaded;
      final isFavorite = await _checkIsFavoriteWallpaperUseCase.execute(
        wallpaper!,
      );
      _isFavorite = isFavorite;
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

  Future<void> toggleFavorite() async {
    if (wallpaper == null) {
      return;
    }

    _viewState = ViewState.favoriteActionLoading;
    notifyListeners();
    bool isFavorite = await _checkIsFavoriteWallpaperUseCase.execute(
      wallpaper!,
    );

    if (isFavorite) {
      try {
        _unfavoriteWallpaperUseCase.execute(wallpaper!);
        _isFavorite = false;
        _viewState = ViewState.favoriteActionLoadingFinished;
      } catch (e) {
        _errorMessage = "Something went wrong, please try again later.";
        _viewState = ViewState.favoriteUnfavoriteOperationError;
      }
    } else {
      try {
        await _favoriteWallpaperUseCase.execute(wallpaper!);
        _isFavorite = true;
        _viewState = ViewState.favoriteActionLoadingFinished;
      } catch (e) {
        _errorMessage = "Something went wrong, please try again later.";
        _viewState = ViewState.favoriteUnfavoriteOperationError;
      }
    }
    notifyListeners();
  }
}

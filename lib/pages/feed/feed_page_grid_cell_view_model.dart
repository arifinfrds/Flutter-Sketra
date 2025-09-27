import 'package:flutter/foundation.dart';

import '../../data/domain/check_is_favorite_wallpaper_use_case.dart';
import '../../data/domain/wallpaper_entity.dart';

final class FeedPageGridCellViewModel extends ChangeNotifier {
  final WallpaperEntity _wallpaper;
  final CheckIsFavoriteWallpaperUseCase _checkIsFavoriteWallpaperUseCase;

  bool _isFavorite = false;

  bool get isFavorite => _isFavorite;

  FeedPageGridCellViewModel(
    this._wallpaper,
    this._checkIsFavoriteWallpaperUseCase,
  );

  Future<void> onLoad() async {
    final isFavorite = await _checkIsFavoriteWallpaperUseCase.execute(
      _wallpaper,
    );
    _isFavorite = isFavorite;
    notifyListeners();
  }
}

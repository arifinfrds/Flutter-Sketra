import 'package:sketra/data/domain/wallpaper_entity.dart';

import '../cache/favorite_wallpaper_store.dart';

abstract class CheckIsFavoriteWallpaperUseCase {
  Future<bool> execute(WallpaperEntity wallpaper);
}

class DefaultCheckIsFavoriteWallpaperUseCase
    extends CheckIsFavoriteWallpaperUseCase {
  final FavoriteWallpaperStore _store;

  DefaultCheckIsFavoriteWallpaperUseCase(this._store);

  @override
  Future<bool> execute(WallpaperEntity wallpaper) async {
    return await _store.isFavorite(wallpaper);
  }
}

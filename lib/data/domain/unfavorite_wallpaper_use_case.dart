import 'package:sketra/data/domain/wallpaper_entity.dart';

import '../cache/favorite_wallpaper_store.dart';

abstract class UnFavoriteWallpaperUseCase {
  Future<void> execute(WallpaperEntity wallpaper);
}

class DefaultUnfavoriteWallpaperUseCase extends UnFavoriteWallpaperUseCase {
  final FavoriteWallpaperStore _store;

  DefaultUnfavoriteWallpaperUseCase(this._store);

  @override
  Future<void> execute(WallpaperEntity wallpaper) {
    try {
      return _store.setWallpaperAsUnfavorite(wallpaper);
    } catch (e) {
      rethrow;
    }
  }
}

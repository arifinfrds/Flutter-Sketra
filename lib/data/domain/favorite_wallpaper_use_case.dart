import 'package:sketra/data/domain/wallpaper_entity.dart';

import '../cache/favorite_wallpaper_store.dart';

abstract class FavoriteWallpaperUseCase {
  Future<void> execute(WallpaperEntity wallpaper);
}

class DefaultFavoriteWallpaperUseCase extends FavoriteWallpaperUseCase {
  final FavoriteWallpaperStore _store;

  DefaultFavoriteWallpaperUseCase(this._store);

  @override
  Future<void> execute(WallpaperEntity wallpaper) {
    try {
      return _store.setWallpaperAsFavorite(wallpaper);
    } catch (e) {
      rethrow;
    }
  }
}
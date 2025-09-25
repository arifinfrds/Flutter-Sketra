import 'dart:ffi';

import '../domain/wallpaper_entity.dart';

abstract class FavoriteWallpaperStore {
  Future<void> setWallpaperAsFavorite(WallpaperEntity wallpaper);

  Future<void> setWallpaperAsUnfavorite(WallpaperEntity wallpaper);

  Future<bool> isFavorite(WallpaperEntity wallpaper);
}
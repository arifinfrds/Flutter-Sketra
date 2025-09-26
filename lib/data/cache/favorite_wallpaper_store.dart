import 'package:hive/hive.dart';
import 'package:sketra/data/cache/cached_wallpaper.dart';

import '../domain/wallpaper_entity.dart';

abstract class FavoriteWallpaperStore {
  Future<void> setWallpaperAsFavorite(WallpaperEntity wallpaper);

  Future<void> setWallpaperAsUnfavorite(WallpaperEntity wallpaper);

  Future<bool> isFavorite(WallpaperEntity wallpaper);
}

class HiveFavoriteWallpaperStore extends FavoriteWallpaperStore {
  final String _boxName = "favorite_wallpapers";
  late Box<CachedWallpaper> _box;

  /// Call this once during app startup
  Future<void> init() async {
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(CachedWallpaperAdapter());
    }
    _box = await Hive.openBox<CachedWallpaper>(_boxName);
  }

  @override
  Future<void> setWallpaperAsFavorite(WallpaperEntity wallpaper) async {
    final cachedWallpaper = CachedWallpaper(id: wallpaper.id);
    await _box.put(wallpaper.id, cachedWallpaper);
  }

  @override
  Future<void> setWallpaperAsUnfavorite(WallpaperEntity wallpaper) async {
    _box.delete(wallpaper.id);
  }

  @override
  Future<bool> isFavorite(WallpaperEntity wallpaper) async {
    return _box.containsKey(wallpaper.id);
  }
}

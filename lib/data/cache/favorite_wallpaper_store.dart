import 'package:hive/hive.dart';
import 'package:sketra/data/cache/cached_wallpaper.dart';
import '../domain/wallpaper_entity.dart';

abstract class FavoriteWallpaperStore {
  Future<void> init();

  Future<void> setWallpaperAsFavorite(WallpaperEntity wallpaper);

  Future<void> setWallpaperAsUnfavorite(WallpaperEntity wallpaper);

  Future<bool> isFavorite(WallpaperEntity wallpaper);
}

class HiveFavoriteWallpaperStore extends FavoriteWallpaperStore {
  final String _boxName = "favorite_wallpapers";
  late Box<CachedWallpaper> _box;

  @override
  Future<void> init() async {
    if (!Hive.isAdapterRegistered(CachedWallpaperAdapter().typeId)) {
      Hive.registerAdapter(CachedWallpaperAdapter());
    }
    _box = await Hive.openBox<CachedWallpaper>(_boxName);
  }

  @override
  Future<void> setWallpaperAsFavorite(WallpaperEntity wallpaper) async {
    await _box.put(wallpaper.id, CachedWallpaper(id: wallpaper.id));
  }

  @override
  Future<void> setWallpaperAsUnfavorite(WallpaperEntity wallpaper) async {
    await _box.delete(wallpaper.id);
  }

  @override
  Future<bool> isFavorite(WallpaperEntity wallpaper) async {
    return _box.containsKey(wallpaper.id);
  }
}

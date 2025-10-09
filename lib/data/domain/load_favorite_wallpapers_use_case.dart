import 'package:sketra/data/domain/check_is_favorite_wallpaper_use_case.dart';
import 'package:sketra/data/domain/wallpaper_entity.dart';
import 'package:sketra/data/networking/json_wallpaper_service.dart';

abstract class LoadFavoriteWallpapersUseCase {
  Future<List<WallpaperEntity>> execute();
}

final class DefaultLoadFavoriteWallpapersUseCase
    implements LoadFavoriteWallpapersUseCase {
  final JsonWallpaperService wallpaperService;
  final CheckIsFavoriteWallpaperUseCase checkIsFavoriteWallpaperUseCase;

  DefaultLoadFavoriteWallpapersUseCase({
    required this.wallpaperService,
    required this.checkIsFavoriteWallpaperUseCase,
  });

  @override
  Future<List<WallpaperEntity>> execute() async {
    final wallpapers = await wallpaperService.loadWallpapers();

    List<WallpaperEntity> favoriteWallpapers = [];
    for (var wallpaper in wallpapers) {
      try {
        final isFavorite = await checkIsFavoriteWallpaperUseCase.execute(
          wallpaper,
        );
        if (isFavorite) {
          favoriteWallpapers.add(wallpaper);
        }
      } catch (e) {
        rethrow;
      }
    }

    return favoriteWallpapers;
  }
}

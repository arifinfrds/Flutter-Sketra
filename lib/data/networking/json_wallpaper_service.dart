import 'package:sketra/data/domain/wallpaper_entity.dart';
import 'package:sketra/data/networking/remote_wallpaper.dart';

import 'remote_wallpaper_response.dart';
import 'dart:convert';

class JsonWallpaperService {
  String jsonString;

  JsonWallpaperService.name(this.jsonString);

  Future<List<WallpaperEntity>> loadWallpapers() async {
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    return RemoteWallpaperResponse.fromJson(
      decoded,
    ).wallpapers.map((item) => item.toEntity()).toList();
  }

  Future<WallpaperEntity> loadWallpaper(String id) async {
    List<WallpaperEntity> wallpapers = await loadWallpapers();
    // Find the wallpaper by id
    final wallpaper = wallpapers.firstWhere(
      (wallpaper) => wallpaper.id == id,
      orElse: () => throw Exception('Wallpaper not found'),
    );

    return wallpaper;
  }
}

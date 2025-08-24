import 'package:sketra/models/wallpaper.dart';

import 'wallpaper_response.dart';
import 'dart:convert';

class MockWallpaperRepository {
  String jsonString;

  MockWallpaperRepository.name(this.jsonString);

  Future<WallpaperResponse> loadWallpapers() async {
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    return WallpaperResponse.fromJson(decoded);
  }

  Future<Wallpaper> loadWallpaper(String id) async {
    WallpaperResponse response = await loadWallpapers();
    List<Wallpaper> wallpapers = response.wallpapers;
    // Find the wallpaper by id
    final wallpaper = wallpapers.firstWhere(
      (wallpaper) => wallpaper.id == id,
      orElse: () => throw Exception('Wallpaper not found'),
    );

    return wallpaper;
  }
}

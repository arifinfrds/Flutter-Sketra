import 'package:sketra/models/remote_wallpaper.dart';

import 'remote_wallpaper_response.dart';
import 'dart:convert';

class JsonWallpaperService {
  String jsonString;

  JsonWallpaperService.name(this.jsonString);

  Future<RemoteWallpaperResponse> loadWallpapers() async {
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    return RemoteWallpaperResponse.fromJson(decoded);
  }

  Future<RemoteWallpaper> loadWallpaper(String id) async {
    RemoteWallpaperResponse response = await loadWallpapers();
    List<RemoteWallpaper> wallpapers = response.wallpapers;
    // Find the wallpaper by id
    final wallpaper = wallpapers.firstWhere(
      (wallpaper) => wallpaper.id == id,
      orElse: () => throw Exception('Wallpaper not found'),
    );

    return wallpaper;
  }
}

import 'remote_wallpaper.dart';

class RemoteWallpaperResponse {
  final List<RemoteWallpaper> wallpapers;

  RemoteWallpaperResponse({required this.wallpapers});

  factory RemoteWallpaperResponse.fromJson(Map<String, dynamic> json) {
    var list = json['wallpapers'] as List;
    List<RemoteWallpaper> wallpapersList = list
        .map((e) => RemoteWallpaper.fromJson(e))
        .toList();

    return RemoteWallpaperResponse(wallpapers: wallpapersList);
  }

  Map<String, dynamic> toJson() {
    return {'wallpapers': wallpapers.map((e) => e.toJson()).toList()};
  }
}

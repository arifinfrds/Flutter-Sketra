import 'Wallpaper.dart';

class WallpaperResponse {
  final List<Wallpaper> wallpapers;

  WallpaperResponse({required this.wallpapers});

  factory WallpaperResponse.fromJson(Map<String, dynamic> json) {
    var list = json['wallpapers'] as List;
    List<Wallpaper> wallpapersList = list
        .map((e) => Wallpaper.fromJson(e))
        .toList();

    return WallpaperResponse(wallpapers: wallpapersList);
  }

  Map<String, dynamic> toJson() {
    return {'wallpapers': wallpapers.map((e) => e.toJson()).toList()};
  }
}

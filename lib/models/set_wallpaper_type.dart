import 'package:wallpaper_manager_flutter/wallpaper_manager_flutter.dart';

enum SetWallpaperType { homeScreen, lockScreen, bothScreens }

extension SetWallpaperTypeExtension on SetWallpaperType {
  int toWallpaperManagerFlutter() {
    switch (this) {
      case SetWallpaperType.homeScreen:
        return WallpaperManagerFlutter.homeScreen;
      case SetWallpaperType.lockScreen:
        return WallpaperManagerFlutter.lockScreen;
      case SetWallpaperType.bothScreens:
        return WallpaperManagerFlutter.bothScreens;
    }
  }
}

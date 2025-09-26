import 'package:hive/hive.dart';

part 'cached_wallpaper.g.dart'; // generated file

@HiveType(typeId: 0)
class CachedWallpaper extends HiveObject {
  @HiveField(0)
  String id;

  CachedWallpaper({required this.id});
}

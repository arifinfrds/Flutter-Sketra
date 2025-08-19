import 'WallpaperResponse.dart';
import 'dart:convert';

class MockWallpaperRepository {
  Future<WallpaperResponse> loadWallpapers(String jsonString) async {
    final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
    return WallpaperResponse.fromJson(decoded);
  }
}

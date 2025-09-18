import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:sketra/constants.dart';
import 'package:sketra/data/networking/set_wallpaper_type.dart';
import 'package:uuid/uuid.dart';
import 'package:wallpaper_manager_flutter/wallpaper_manager_flutter.dart';

class DownloadWallpaperService {
  final Dio _dio = Dio();

  Future<void> downloadImage(String imageUrl) async {
    try {
      final response = await _dio.get(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      final result = await ImageGallerySaverPlus.saveImage(
        Uint8List.fromList(response.data),
        quality: 100,
        name: _makeImageName(),
      );

      print("Image saved: $result");
    } catch (e) {
      print("Error saving image: $e");
      rethrow;
    }
  }

  Future<void> setImageAsSystemWallpaper(
    String imageUrl,
    SetWallpaperType setWallpaperType,
  ) async {
    if (!Platform.isAndroid) {
      throw UnsupportedError("Setting wallpaper is only supported on Android");
    }

    try {
      final response = await _dio.get(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      final tempDir = Directory.systemTemp;
      final file = File('${tempDir.path}/${_makeImageName()}.png');
      await file.writeAsBytes(response.data);

      await WallpaperManagerFlutter().setWallpaper(
        file,
        setWallpaperType.toWallpaperManagerFlutter(),
      );

      print("✅ Wallpaper set successfully");
    } catch (e) {
      print("Error saving image: $e");
      rethrow;
    }
  }

  String _makeImageName() {
    final uuid = const Uuid().v4();
    return '$kAppName-wallpaper-$uuid';
  }
}

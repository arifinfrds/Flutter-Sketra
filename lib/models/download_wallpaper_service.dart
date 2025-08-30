import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:sketra/constants.dart';
import 'package:uuid/uuid.dart';

class DownloadWallpaperService {
  final Dio _dio = Dio();

  Future<void> downloadImage(String imageUrl) async {
    try {
      final response = await _dio.get(
        imageUrl,
        options: Options(responseType: ResponseType.bytes),
      );

      // Save image to gallery
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

  String _makeImageName() {
    final uuid = const Uuid().v4();
    return '${kAppName}-wallpaper-${uuid}';
  }
}

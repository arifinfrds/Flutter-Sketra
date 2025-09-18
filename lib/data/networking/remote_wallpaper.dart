import '../domain/wallpaper_entity.dart';

class RemoteWallpaper {
  final String id;
  final String title;
  final String url;
  final String category;
  final DateTime creationDate;

  RemoteWallpaper({
    required this.id,
    required this.title,
    required this.url,
    required this.category,
    required this.creationDate,
  });

  factory RemoteWallpaper.fromJson(Map<String, dynamic> json) {
    return RemoteWallpaper(
      id: json['id'] as String,
      title: json['title'] as String,
      url: json['url'] as String,
      category: json['category'] as String,
      creationDate: DateTime.parse(json['creationDate'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'url': url,
      'category': category,
      'creationDate': creationDate.toIso8601String(),
    };
  }
}

extension RemoteWallpaperExtension on RemoteWallpaper {
  WallpaperEntity toEntity() {
    return WallpaperEntity(
      id: id,
      title: title,
      url: url,
      category: category,
      creationDate: creationDate,
    );
  }
}
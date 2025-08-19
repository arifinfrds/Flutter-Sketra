class Wallpaper {
  final String id;
  final String title;
  final String url;
  final String category;
  final DateTime creationDate;

  Wallpaper({
    required this.id,
    required this.title,
    required this.url,
    required this.category,
    required this.creationDate,
  });

  factory Wallpaper.fromJson(Map<String, dynamic> json) {
    return Wallpaper(
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

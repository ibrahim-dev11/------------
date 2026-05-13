class BannerModel {
  final int id;
  final String title;
  final String? subtitle;
  final String? tag;
  final String? imageUrl;
  final String colorStart;
  final String colorEnd;

  const BannerModel({
    required this.id,
    required this.title,
    this.subtitle,
    this.tag,
    this.imageUrl,
    required this.colorStart,
    required this.colorEnd,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? '',
      subtitle: json['subtitle'] as String?,
      tag: json['tag'] as String?,
      imageUrl: json['image_url'] as String?,
      colorStart: json['color_start'] as String? ?? '#C49A3C',
      colorEnd: json['color_end'] as String? ?? '#E0B856',
    );
  }
}

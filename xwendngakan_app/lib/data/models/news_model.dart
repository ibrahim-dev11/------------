import '../../core/constants/app_constants.dart';

class NewsModel {
  final int id;
  final String title;
  final String content;
  final String? imageUrl;
  final String createdAt;

  NewsModel({
    required this.id,
    required this.title,
    required this.content,
    this.imageUrl,
    required this.createdAt,
  });

  String get displayImageUrl {
    if (imageUrl == null || imageUrl!.isEmpty) return '';
    if (imageUrl!.contains('localhost') || imageUrl!.contains('127.0.0.1')) {
      final base = AppConstants.baseUrl.replaceAll('/api', '');
      final uri = Uri.parse(imageUrl!);
      return '$base${uri.path}';
    }
    return imageUrl!;
  }

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'] as int,
      title: json['title'] as String,
      content: json['content'] as String,
      imageUrl: json['image_url'] as String?,
      createdAt: json['created_at'] as String,
    );
  }
}

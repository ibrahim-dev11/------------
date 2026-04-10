import '../services/api_service.dart';

class Post {
  int id;
  int institutionId;
  String title;
  String content;
  String image;
  String authorName;
  String createdAt;
  bool approved;

  Post({
    required this.id,
    required this.institutionId,
    this.title = '',
    this.content = '',
    this.image = '',
    this.authorName = '',
    this.createdAt = '',
    this.approved = false,
  });

  /// Build the server base URL (without /api)
  static String get _serverBase => ApiService.serverBase;

  /// Convert a relative storage path to full URL
  static String _resolveUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http')) {
      // For Android emulator, replace 127.0.0.1 with 10.0.2.2
      return path.replaceFirst('http://127.0.0.1', 'http://10.0.2.2');
    }
    return '$_serverBase${path.startsWith('/') ? '' : '/'}$path';
  }

  factory Post.fromJson(Map<String, dynamic> j) => Post(
        id: j['id'] ?? 0,
        institutionId: j['institution_id'] ?? 0,
        title: j['title'] ?? '',
        content: j['content'] ?? '',
        image: _resolveUrl(j['image']),
        authorName: j['author_name'] ?? j['user_name'] ?? '',
        createdAt: j['created_at'] ?? '',
        approved: j['approved'] == true || j['approved'] == 1,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'institution_id': institutionId,
        'title': title,
        'content': content,
        'image': image,
        'author_name': authorName,
        'approved': approved,
      };

  /// Format the date nicely
  String get formattedDate {
    try {
      final dt = DateTime.parse(createdAt);
      final now = DateTime.now();
      final diff = now.difference(dt);

      if (diff.inMinutes < 1) return 'ئێستا';
      if (diff.inHours < 1) return '${diff.inMinutes} خولەک';
      if (diff.inDays < 1) return '${diff.inHours} کاتژمێر';
      if (diff.inDays < 7) return '${diff.inDays} ڕۆژ';
      if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} هەفتە';
      return '${dt.year}/${dt.month}/${dt.day}';
    } catch (_) {
      return createdAt;
    }
  }
}

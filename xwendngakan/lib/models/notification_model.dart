class NotificationModel {
  final String id;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic> data;
  final DateTime? readAt;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    required this.data,
    this.readAt,
    required this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // Laravel notifications table stores data as a JSON string or array in the 'data' column
    final dataMap = json['data'] as Map<String, dynamic>? ?? {};
    
    return NotificationModel(
      id: json['id'],
      type: json['type'],
      title: dataMap['title'] ?? 'نۆتیفیکەیشن',
      body: dataMap['body'] ?? '',
      data: dataMap,
      readAt: json['read_at'] != null ? DateTime.parse(json['read_at']) : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  bool get isRead => readAt != null;

  bool get isPost {
    if (data.containsKey('type') && data['type'] == 'post') return true;
    if (data.containsKey('data') && data['data'] is Map) {
      final nested = data['data'] as Map;
      if (nested['type'] == 'post') return true;
    }
    return false;
  }
}

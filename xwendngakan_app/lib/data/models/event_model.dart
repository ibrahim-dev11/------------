class EventModel {
  final int id;
  final String title;
  final String description;
  final String? imageUrl;
  final String startDate;
  final String? endDate;
  final String? location;
  final String? organizer;
  final String createdAt;

  EventModel({
    required this.id,
    required this.title,
    required this.description,
    this.imageUrl,
    required this.startDate,
    this.endDate,
    this.location,
    this.organizer,
    required this.createdAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String,
      imageUrl: json['image_url'] as String?,
      startDate: json['start_date'] as String,
      endDate: json['end_date'] as String?,
      location: json['location'] as String?,
      organizer: json['organizer'] as String?,
      createdAt: json['created_at'] as String,
    );
  }
}

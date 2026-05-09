class UserModel {
  final int id;
  final String name;
  final String email;
  final bool isAdmin;
  final bool notificationsEnabled;
  final String? createdAt;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.isAdmin = false,
    this.notificationsEnabled = true,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      isAdmin: json['is_admin'] ?? false,
      notificationsEnabled: json['notifications_enabled'] ?? true,
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'is_admin': isAdmin,
    'notifications_enabled': notificationsEnabled,
  };
}

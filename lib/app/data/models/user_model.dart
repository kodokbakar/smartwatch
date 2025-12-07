class AppUser {
  final String id;
  final String email;
  final String username;
  final String? fullName;
  final DateTime createdAt;

  AppUser({
    required this.id,
    required this.email,
    required this.username,
    this.fullName,
    required this.createdAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String,
      username: json['username'] as String,
      fullName: json['full_name'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'full_name': fullName,
      'created_at': createdAt.toIso8601String(),
    };
  }

  String get displayName {
    if (fullName != null && fullName!.trim().isNotEmpty) {
      return fullName!;
    }
    return username;
  }
}

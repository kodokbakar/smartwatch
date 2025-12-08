class HelperRequest {
  final String id;
  final String username;
  final String email;
  final String? fullName;
  final String message;
  final DateTime sentAt;

  HelperRequest({
    required this.id,
    required this.username,
    required this.email,
    this.fullName,
    required this.message,
    required this.sentAt,
  });

  factory HelperRequest.fromJson(Map<String, dynamic> json) {
    return HelperRequest(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      message: json['message'] as String,
      sentAt: DateTime.parse(json['sent_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'full_name': fullName,
      'message': message,
      'sent_at': sentAt.toIso8601String(),
    };
  }
}

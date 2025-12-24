class LaporanModel {
  final String id;
  final String judul;
  final String deskripsi;
  final String status;
  final DateTime createdAt;

  LaporanModel({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.status,
    required this.createdAt,
  });

  factory LaporanModel.fromJson(Map<String, dynamic> json) {
    return LaporanModel(
      id: json['id'],
      judul: json['judul'],
      deskripsi: json['deskripsi'],
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays > 0) return '${diff.inDays} hari lalu';
    if (diff.inHours > 0) return '${diff.inHours} jam lalu';
    return '${diff.inMinutes} menit lalu';
  }
}

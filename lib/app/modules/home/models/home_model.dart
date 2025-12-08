class Laporan {
  final String id;
  final String judul;
  final String deskripsi;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;

  Laporan({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Laporan.fromJson(Map<String, dynamic> json) {
    final created = DateTime.parse(json['created_at'] as String);
    final updatedRaw = json['updated_at'];
    final updated = updatedRaw == null
        ? created
        : DateTime.parse(updatedRaw as String);

    return Laporan(
      id: json['id'] as String,
      judul: json['judul'] as String,
      deskripsi: json['deskripsi'] as String,
      status: json['status'] as String,
      createdAt: created,
      updatedAt: updated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'deskripsi': deskripsi,
      'status': status,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // Untuk tampilan kartu
  String get kode {
    // #RPT-<8 karakter pertama id>
    final shortId =
        id.length > 8 ? id.substring(0, 8).toUpperCase() : id.toUpperCase();
    return '#RPT-$shortId';
  }

  String get createdLabel => _formatDate(createdAt);
  String get updatedLabel => _formatDate(updatedAt);

  static String _formatDate(DateTime date) {
    const bulan = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    return '${date.day} ${bulan[date.month]} ${date.year}';
  }
}

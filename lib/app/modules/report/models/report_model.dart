// Model untuk Aktivitas Distribusi
class ActivityModel {
  final String id;
  final String namaProyek;
  final String totalDana;
  final String status;
  final double progress;
  final DateTime createdAt;
  final DateTime? updatedAt;

  ActivityModel({
    required this.id,
    required this.namaProyek,
    required this.totalDana,
    required this.status,
    required this.progress,
    required this.createdAt,
    this.updatedAt,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    final created = DateTime.parse(json['created_at'] as String);
    final updatedRaw = json['updated_at'];

    DateTime? updated;
    if (updatedRaw != null) {
      updated = DateTime.parse(updatedRaw as String);
    }

    return ActivityModel(
      id: json['id'] as String,
      namaProyek: json['nama_proyek'] as String,
      totalDana: json['total_dana'] as String,
      status: json['status'] as String,
      progress: (json['progress'] ?? 0).toDouble(),
      createdAt: created,
      updatedAt: updated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_proyek': namaProyek,
      'total_dana': totalDana,
      'status': status,
      'progress': progress,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

// Model untuk Summary Dashboard
class DashboardSummary {
  final String totalAnggaran;
  final String totalRealisasi;
  final int totalProyek;
  final String totalDana;

  DashboardSummary({
    required this.totalAnggaran,
    required this.totalRealisasi,
    required this.totalProyek,
    required this.totalDana,
  });

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    return DashboardSummary(
      totalAnggaran: json['total_anggaran'] as String,
      totalRealisasi: json['total_realisasi'] as String,
      totalProyek: json['total_proyek'] as int,
      totalDana: json['total_dana'] as String,
    );
  }
}
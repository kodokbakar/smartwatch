import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class DistributionActivitiesController extends GetxController {
  final selectedTab = 0.obs;

  // Statistik bagian atas (diambil dari view v_laporan_overview)
  final RxInt laporanAktif = 0.obs;
  final RxInt dalamAntrean = 0.obs;
  final RxInt tingkatRespons = 0.obs;

  // Statistik bagian bawah (diambil dari view v_laporan_user_stats)
  final RxInt totalLaporan = 0.obs;
  final RxInt ditinjau = 0.obs;
  final RxInt ditindaklanjuti = 0.obs;
  final RxInt selesai = 0.obs;

  // Daftar laporan terbaru (diambil dari tabel public.laporan)
  final RxList<ReportModel> reports = <ReportModel>[].obs;

  // Supabase client (pastikan Supabase.initialize sudah dipanggil di main.dart)
  SupabaseClient get _db => Supabase.instance.client;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  void changeTab(int index) => selectedTab.value = index;

  Future<void> loadData() async {
    try {
      // -----------------------------------------------------------------------
      // 1) Ambil statistik global yang bisa diakses user (tergantung RLS/policy).
      // -----------------------------------------------------------------------
      final overview = await _db
          .from('v_laporan_overview')
          .select()
          .maybeSingle();

      if (overview != null) {
        laporanAktif.value = (overview['laporan_aktif'] ?? 0) as int;
        dalamAntrean.value = (overview['dalam_antrean'] ?? 0) as int;
        tingkatRespons.value = (overview['tingkat_respons'] ?? 0) as int;
      }

      // -----------------------------------------------------------------------
      // 2) Ambil statistik laporan milik user saat ini.
      //    Jika belum login, aman-set ke 0 agar UI tidak menyesatkan.
      // -----------------------------------------------------------------------
      final userId = _db.auth.currentUser?.id;
      if (userId != null) {
        final userStats = await _db
            .from('v_laporan_user_stats')
            .select()
            .eq('user_id', userId)
            .maybeSingle();

        totalLaporan.value = (userStats?['total_laporan'] ?? 0) as int;
        ditinjau.value = (userStats?['ditinjau'] ?? 0) as int;
        ditindaklanjuti.value = (userStats?['ditindaklanjuti'] ?? 0) as int;
        selesai.value = (userStats?['selesai'] ?? 0) as int;
      } else {
        totalLaporan.value = 0;
        ditinjau.value = 0;
        ditindaklanjuti.value = 0;
        selesai.value = 0;
      }

      // -----------------------------------------------------------------------
      // 3) Ambil list laporan terbaru untuk section "Laporan Terbaru"
      // -----------------------------------------------------------------------
      final rows = await _db
          .from('laporan')
          .select('id, judul, deskripsi, status, created_at')
          // Ambil data terbaru terlebih dahulu
          .order('created_at', ascending: false)
          .limit(20);

      reports.value = (rows as List)
          .map((e) => ReportModel.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Error ditampilkan ke user, tetapi aplikasi tidak crash.
      Get.snackbar(
        'Gagal memuat data',
        e.toString(),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        duration: const Duration(seconds: 3),
      );
    }
  }

  void openReportDetail(ReportModel report) {
    Get.snackbar(
      'Detail Laporan',
      report.title,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.shade100,
      colorText: Colors.blue.shade900,
      duration: const Duration(seconds: 2),
    );

    // TODO: Arahkan ke halaman detail, gunakan UUID String:
    // Get.toNamed(Routes.REPORT_DETAIL, arguments: report.id);
  }
}

class ReportModel {
  /// UUID dari `public.laporan.id`
  final String id;

  /// Judul laporan (kolom: judul)
  final String title;

  /// Deskripsi laporan (kolom: deskripsi)
  final String description;

  /// Status laporan (enum di DB: public.laporan_status)
  final String status;

  /// Waktu pembuatan laporan (kolom: created_at) untuk menghitung `timeAgo`
  final DateTime createdAt;

  ReportModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.createdAt,
  });

  /// Teks waktu relatif yang selalu akurat walau screen dibiarkan terbuka.
  String get timeAgo => _timeAgo(createdAt);

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    final created = DateTime.tryParse(json['created_at']?.toString() ?? '');

    return ReportModel(
      id: json['id']?.toString() ?? '',
      title: json['judul']?.toString() ?? '',
      description: json['deskripsi']?.toString() ?? '',
      status: _normalizeStatus(json['status']?.toString()),
      createdAt: created ?? DateTime.now(),
    );
  }

  /// Normalisasi status untuk menjaga konsistensi UI.
  /// "Sedang Proses" dianggap setara "Dalam Antrean".
  static String _normalizeStatus(String? status) {
    if (status == null || status.isEmpty) return 'Dalam Antrean';
    if (status == 'Sedang Proses') return 'Dalam Antrean';
    return status;
  }

  /// Formatter sederhana tanpa dependency tambahan.
  static String _timeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit yang lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam yang lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari yang lalu';

    final y = dateTime.year.toString().padLeft(4, '0');
    final m = dateTime.month.toString().padLeft(2, '0');
    final d = dateTime.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }
}

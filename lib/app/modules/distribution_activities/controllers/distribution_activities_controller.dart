import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../models/laporan_model.dart';

class DistributionActivitiesController extends GetxController {
  final supabase = Supabase.instance.client;

  // GA4 instance
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  // STATE
  final RxBool isLoading = false.obs;
  final RxList<LaporanModel> reports = <LaporanModel>[].obs;

  // Statistik
  final RxInt laporanAktif = 0.obs;
  final RxInt dalamAntrean = 0.obs;
  final RxInt ditinjau = 0.obs;
  final RxInt ditindaklanjuti = 0.obs;
  final RxInt selesai = 0.obs;

  final RxInt totalLaporan = 0.obs;
  final RxInt tingkatRespons = 0.obs;

  @override
  void onInit() {
    super.onInit();

    // GA4: catat screen distribusi dibuka
    _analytics.logScreenView(screenName: 'distribution_activities');
    _analytics.logEvent(name: 'distribution_activities_open');

    fetchAllData();
  }

  Future<void> fetchAllData() async {
    isLoading.value = true;

    // GA4: mulai ambil semua data
    _analytics.logEvent(name: 'distribution_fetch_all_start');

    try {
      await Future.wait([
        fetchLaporan(),
        fetchLaporanStats(),
      ]);

      // GA4: sukses ambil semua data (kirim angka ringkas saja)
      _analytics.logEvent(
        name: 'distribution_fetch_all_success',
        parameters: {
          'reports_count': reports.length,
          'total_laporan': totalLaporan.value,
          'aktif': laporanAktif.value,
          'selesai': selesai.value,
          'tingkat_respons': tingkatRespons.value,
        },
      );
    } catch (_) {
      // GA4: gagal ambil data (reason dibuat generik)
      _analytics.logEvent(
        name: 'distribution_fetch_all_failed',
        parameters: {'reason': 'exception'},
      );
      rethrow;
    } finally {
      isLoading.value = false;
    }
  }

  // ======================
  // FETCH LAPORAN LIST
  // ======================
  Future<void> fetchLaporan() async {
    final userId = supabase.auth.currentUser?.id;

    // Kalau user belum login, hentikan dan catat event.
    if (userId == null) {
      _analytics.logEvent(
        name: 'distribution_fetch_all_failed',
        parameters: {'reason': 'not_logged_in'},
      );
      return;
    }

    final res = await supabase
        .from('laporan')
        .select('id, judul, deskripsi, status, created_at')
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(10);

    reports.value =
        (res as List).map((e) => LaporanModel.fromJson(e)).toList();

    // GA4: fetch list sukses (hanya jumlah, tanpa isi laporan)
    _analytics.logEvent(
      name: 'distribution_reports_fetch_success',
      parameters: {'count': reports.length},
    );
  }

  // ======================
  // FETCH STATISTIK
  // ======================
  Future<void> fetchLaporanStats() async {
    final userId = supabase.auth.currentUser?.id;

    if (userId == null) {
      _analytics.logEvent(
        name: 'distribution_fetch_all_failed',
        parameters: {'reason': 'not_logged_in'},
      );
      return;
    }

    final res = await supabase
        .from('laporan')
        .select('status')
        .eq('user_id', userId);

    totalLaporan.value = res.length;

    laporanAktif.value = res.where((e) => e['status'] != 'Selesai').length;
    dalamAntrean.value = res.where((e) => e['status'] == 'Dalam Antrean').length;
    ditinjau.value = res.where((e) => e['status'] == 'Ditinjau').length;
    ditindaklanjuti.value =
        res.where((e) => e['status'] == 'Ditindaklanjuti').length;
    selesai.value = res.where((e) => e['status'] == 'Selesai').length;

    tingkatRespons.value = totalLaporan.value == 0
        ? 0
        : ((selesai.value / totalLaporan.value) * 100).round();

    // GA4: fetch statistik sukses (angka ringkas untuk dashboard)
    _analytics.logEvent(
      name: 'distribution_stats_fetch_success',
      parameters: {
        'total': totalLaporan.value,
        'aktif': laporanAktif.value,
        'selesai': selesai.value,
        'tingkat_respons': tingkatRespons.value,
      },
    );
  }

  // ======================
  // ACTION
  // ======================
  void openReportDetail(LaporanModel laporan) {
    // GA4: user membuka detail laporan dari halaman distribusi
    _analytics.logEvent(
      name: 'distribution_report_detail_open',
      parameters: {'status': laporan.status},
    );

    // Get.toNamed(...)
  }

  Future<void> refreshData() async {
    // GA4: refresh manual
    _analytics.logEvent(name: 'distribution_refresh');

    await fetchAllData();
  }
}

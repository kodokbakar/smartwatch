import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/laporan_model.dart';

class DistributionActivitiesController extends GetxController {
  final supabase = Supabase.instance.client;

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
    fetchAllData();
  }

  Future<void> fetchAllData() async {
    isLoading.value = true;
    await Future.wait([
      fetchLaporan(),
      fetchLaporanStats(),
    ]);
    isLoading.value = false;
  }

  // ======================
  // FETCH LAPORAN LIST
  // ======================
  Future<void> fetchLaporan() async {
    final userId = supabase.auth.currentUser?.id;

    final res = await supabase
        .from('laporan')
        .select('id, judul, deskripsi, status, created_at')
        .eq('user_id', userId!)
        .order('created_at', ascending: false)
        .limit(10);

    reports.value =
        (res as List).map((e) => LaporanModel.fromJson(e)).toList();
  }

  // ======================
  // FETCH STATISTIK
  // ======================
  Future<void> fetchLaporanStats() async {
    final userId = supabase.auth.currentUser?.id;

    final res = await supabase
        .from('laporan')
        .select('status')
        .eq('user_id', userId!);

    totalLaporan.value = res.length;

    laporanAktif.value =
        res.where((e) => e['status'] != 'Selesai').length;

    dalamAntrean.value =
        res.where((e) => e['status'] == 'Dalam Antrean').length;

    ditinjau.value =
        res.where((e) => e['status'] == 'Ditinjau').length;

    ditindaklanjuti.value =
        res.where((e) => e['status'] == 'Ditindaklanjuti').length;

    selesai.value =
        res.where((e) => e['status'] == 'Selesai').length;

    tingkatRespons.value = totalLaporan.value == 0
        ? 0
        : ((selesai.value / totalLaporan.value) * 100).round();
  }

  // ======================
  // ACTION
  // ======================
  void openReportDetail(LaporanModel laporan) {
    // Get.toNamed(...)
  }

  Future<void> refreshData() async {
    await fetchAllData();
  }
}

import 'dart:async'; // untuk unawaited
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import '../models/home_model.dart';

/// Abstraksi GA4 agar mudah di-unit test (bisa inject no-op/mock).
typedef AnalyticsLogEventFn = Future<void> Function({
  required String name,
  Map<String, Object?>? parameters,
});

typedef AnalyticsLogScreenViewFn = Future<void> Function({
  required String screenName,
});

class HomeController extends GetxController {
  HomeController({
    SupabaseClient? supabase,
    AnalyticsLogEventFn? analyticsLogEvent,
    AnalyticsLogScreenViewFn? analyticsLogScreenView,
  })  : _supabase = supabase ?? Supabase.instance.client,
        _analyticsLogEvent = analyticsLogEvent ?? _firebaseLogEvent,
        _analyticsLogScreenView =
            analyticsLogScreenView ?? _firebaseLogScreenView;

  final SupabaseClient _supabase;

  // GA4 handlers
  final AnalyticsLogEventFn _analyticsLogEvent;
  final AnalyticsLogScreenViewFn _analyticsLogScreenView;

  final selectedTab = 0.obs;

  final totalKasus = 0.obs;
  final totalLaporan = 0.obs;
  final sedangProses = 0.obs;
  final selesai = 0.obs;

  final laporanController = TextEditingController(); // judul
  final deskripsiController = TextEditingController(); // deskripsi

  final isLoading = false.obs;
  final isSubmitting = false.obs;

  // Monthly statistics data (diisi dari Supabase)
  final monthlyStats = <Map<String, dynamic>>[].obs;

  // Laporan dari Supabase
  final laporanList = <Laporan>[].obs;

  @override
  void onInit() {
    super.onInit();

    // GA4: catat dashboard dibuka (screen + event).
    unawaited(_analyticsLogScreenView(screenName: 'dashboard'));
    unawaited(_analyticsLogEvent(name: 'dashboard_open'));

    fetchReports();
  }

  @override
  void onClose() {
    laporanController.dispose();
    deskripsiController.dispose();
    super.onClose();
  }

  // === DATA ===

  Future<void> fetchReports() async {
    isLoading.value = true;

    // GA4: mulai fetch laporan.
    unawaited(_analyticsLogEvent(name: 'reports_fetch_start'));

    try {
      final data = await _supabase
          .from('laporan')
          .select()
          .order('created_at', ascending: false);

      final list = (data as List)
          .map((row) => Laporan.fromJson(row as Map<String, dynamic>))
          .toList();

      laporanList.assignAll(list);

      totalLaporan.value = list.length;
      totalKasus.value = list.length; // bisa diubah kalau ada metrik lain
      sedangProses.value =
          list.where((l) => l.status == 'Sedang Proses').length;
      selesai.value = list.where((l) => l.status == 'Selesai').length;

      _recalculateMonthlyStats(list);

      // GA4: fetch sukses + metrik ringkas (tanpa data sensitif).
      unawaited(_analyticsLogEvent(
        name: 'reports_fetch_success',
        parameters: {
          'total': totalLaporan.value,
          'sedang_proses': sedangProses.value,
          'selesai': selesai.value,
        },
      ));
    } catch (e) {
      // GA4: fetch gagal (reason dibuat generik agar aman).
      unawaited(_analyticsLogEvent(
        name: 'reports_fetch_failed',
        parameters: {'reason': 'exception'},
      ));

      Get.snackbar(
        'Error',
        'Gagal memuat laporan: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  /// Dipakai oleh RefreshIndicator
  Future<void> onRefresh() async {
    // GA4: user melakukan refresh manual.
    unawaited(_analyticsLogEvent(name: 'dashboard_refresh'));

    await fetchReports();
  }

  List<Laporan> get filteredReports {
    if (selectedTab.value == 1) {
      return laporanList.where((l) => l.status == 'Sedang Proses').toList();
    }
    if (selectedTab.value == 2) {
      return laporanList.where((l) => l.status == 'Selesai').toList();
    }
    return laporanList;
  }

  void _recalculateMonthlyStats(List<Laporan> list) {
    if (list.isEmpty) {
      // fallback: 4 bulan terakhir dari sekarang dengan nilai 0
      final now = DateTime.now();
      final stats = List.generate(4, (i) {
        final d = DateTime(now.year, now.month - (3 - i), 1);
        return {
          'month': _monthShortName(d.month),
          'value': 0.0,
        };
      });
      monthlyStats.assignAll(stats);
      return;
    }

    // Hitung jumlah laporan per (tahun, bulan) berdasarkan effectiveDate
    final Map<int, int> counts = {}; // key = year * 100 + month
    for (final l in list) {
      final d = l.effectiveDate;
      final key = d.year * 100 + d.month;
      counts[key] = (counts[key] ?? 0) + 1;
    }

    // Ambil maksimal 4 bulan terakhir yang punya data
    final keys = counts.keys.toList()..sort(); // ascending
    final last4 = keys.length > 4 ? keys.sublist(keys.length - 4) : keys;

    // cari count terbesar untuk normalisasi tinggi bar
    int maxCount = 0;
    for (final k in last4) {
      final c = counts[k] ?? 0;
      if (c > maxCount) maxCount = c;
    }
    if (maxCount == 0) maxCount = 1;
    const double maxHeight = 100.0;

    final stats = last4.map((k) {
      final c = counts[k] ?? 0;
      final year = k ~/ 100;
      final month = k % 100;
      final label = _monthShortName(month);
      final value = (c / maxCount) * maxHeight; // skala 0–100
      return {
        'month': '$label',
        'value': value,
        'year': year,
      };
    }).toList();

    monthlyStats.assignAll(stats);
  }

  String _monthShortName(int month) {
    const months = [
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
      'Des',
    ];
    if (month < 1 || month > 12) return '';
    return months[month];
  }

  // === UI actions ===

  void changeTab(int index) {
    selectedTab.value = index;

    // GA4: user mengganti tab (0=Semua, 1=Sedang Proses, 2=Selesai).
    unawaited(_analyticsLogEvent(
      name: 'dashboard_tab_change',
      parameters: {'tab_index': index},
    ));
  }

  void openProfile() {
    // GA4: user membuka profile dari dashboard.
    unawaited(_analyticsLogEvent(name: 'profile_open_from_dashboard'));
    Get.toNamed('/profile');
  }

  void createNewReport() {
    // GA4: user membuka bottom sheet buat laporan baru.
    unawaited(_analyticsLogEvent(name: 'report_create_open'));

    Get.bottomSheet(
      _buildReportBottomSheet(),
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildReportBottomSheet() {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(Get.context!).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 20),
                  onPressed: () => Get.back(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Laporan Baru',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            const Text(
              'Laporan',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: laporanController,
              decoration: InputDecoration(
                hintText: 'Laporan',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue.shade700),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Deskripsi Laporan',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: deskripsiController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Deskripsi Laporan',
                hintStyle: TextStyle(color: Colors.grey.shade400),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.blue.shade700),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
            const SizedBox(height: 32),

            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isSubmitting.value ? null : submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade400,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 0,
                  ),
                  child: isSubmitting.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Submit',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> submitReport() async {
    final judul = laporanController.text.trim();
    final deskripsi = deskripsiController.text.trim();

    // GA4: user menekan submit (attempt).
    unawaited(_analyticsLogEvent(name: 'report_submit_attempt'));

    if (judul.isEmpty || deskripsi.isEmpty) {
      // GA4: validasi gagal, jangan kirim isi judul/deskripsi.
      unawaited(_analyticsLogEvent(
        name: 'report_submit_validation_failed',
        parameters: {'reason': 'empty_field'},
      ));

      Get.snackbar(
        'Error',
        'Mohon isi semua field',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
      return;
    }

    try {
      isSubmitting.value = true;

      final authUser = _supabase.auth.currentUser;
      final insertData = {
        'judul': judul,
        'deskripsi': deskripsi,
        'status': 'Sedang Proses',
        'user_id': authUser?.id,
      };

      final inserted = await _supabase
          .from('laporan')
          .insert(insertData)
          .select()
          .single();

      final newLaporan = Laporan.fromJson(inserted as Map<String, dynamic>);
      laporanList.insert(0, newLaporan);

      totalLaporan.value++;
      totalKasus.value++;
      sedangProses.value++;

      _recalculateMonthlyStats(laporanList);

      // GA4: submit sukses.
      unawaited(_analyticsLogEvent(
        name: 'report_submit_success',
        parameters: {'status': 'Sedang Proses'},
      ));

      Get.back();
      Get.snackbar(
        'Berhasil',
        'Laporan berhasil disimpan',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade400,
        colorText: Colors.white,
      );

      laporanController.clear();
      deskripsiController.clear();
    } catch (e) {
      // GA4: submit gagal.
      unawaited(_analyticsLogEvent(
        name: 'report_submit_failed',
        parameters: {'reason': 'exception'},
      ));

      Get.snackbar(
        'Error',
        'Gagal menyimpan laporan: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  void openReportDetail(Laporan laporan) {
    // GA4: user membuka detail laporan.
    unawaited(_analyticsLogEvent(
      name: 'report_detail_open',
      parameters: {
        'status': laporan.status, // aman, bukan PII
      },
    ));

    Get.toNamed('/report-detail', arguments: laporan);
  }

  // ===== GA4 default implementations (Production) =====

  static Future<void> _firebaseLogScreenView({
    required String screenName,
  }) {
    return FirebaseAnalytics.instance.logScreenView(screenName: screenName);
  }

  static Future<void> _firebaseLogEvent({
    required String name,
    Map<String, Object?>? parameters,
  }) {
    // FirebaseAnalytics.logEvent butuh Map<String, Object> tanpa nilai null.
    Map<String, Object>? cleaned;

    if (parameters != null) {
      final tmp = <String, Object>{};
      for (final entry in parameters.entries) {
        final v = entry.value;
        if (v == null) continue;

        // Tipe parameter yang aman untuk GA4: String / int / double.
        if (v is String || v is int || v is double) {
          tmp[entry.key] = v;
        } else if (v is bool) {
          tmp[entry.key] = v ? 1 : 0;
        } else {
          tmp[entry.key] = v.toString();
        }
      }
      cleaned = tmp.isEmpty ? null : tmp;
    }

    return FirebaseAnalytics.instance.logEvent(
      name: name,
      parameters: cleaned,
    );
  }
}

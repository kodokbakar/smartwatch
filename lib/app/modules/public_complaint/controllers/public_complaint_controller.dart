import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/public_complaint_models.dart';

class PublicComplaintController extends GetxController {
  final SupabaseClient _db = Supabase.instance.client;

  // =======================
  // TAB
  // =======================
  final RxInt selectedTab = 0.obs;

  // =======================
  // SUMMARY
  // =======================
  final RxInt totalReports = 0.obs;
  final RxInt completedCases = 0.obs;

  // =======================
  // CATEGORY
  // =======================
  final RxInt penyalahgunaanWewenang = 0.obs;
  final RxInt diskriminasi = 0.obs;
  final RxInt kekerasanBerlebihan = 0.obs;

  // =======================
  // TREND
  // =======================
  final RxList<PublicComplaintTrend> trendData =
      <PublicComplaintTrend>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  void changeTab(int index) {
    selectedTab.value = index;
    loadData();
  }

  // =======================
  // LOAD ALL (SATU SUMBER DATA)
  // =======================
  Future<void> loadData() async {
    try {
      final rows = await _db
          .from('laporan')
          .select('status, kategori, created_at');

      _processSummary(rows);
      _processCategories(rows);
      _processTrend(rows);
    } catch (e) {
      debugPrint('Error load data public complaint: $e');
    }
  }

  // =======================
  // SUMMARY (SAMA DENGAN DASHBOARD)
  // =======================
  void _processSummary(List<dynamic> rows) {
    totalReports.value = rows.length;

    completedCases.value =
        rows.where((e) => e['status'] == 'Selesai').length;
  }

  // =======================
  // CATEGORY (TANPA QUERY ULANG)
  // =======================
  void _processCategories(List<dynamic> rows) {
    penyalahgunaanWewenang.value = 0;
    diskriminasi.value = 0;
    kekerasanBerlebihan.value = 0;

    for (final row in rows) {
      final kategori = row['kategori'];

      if (kategori == 'Penyalahgunaan Wewenang') {
        penyalahgunaanWewenang.value++;
      } else if (kategori == 'Diskriminasi') {
        diskriminasi.value++;
      } else if (kategori == 'Kekerasan Berlebihan') {
        kekerasanBerlebihan.value++;
      }
    }
  }

  // =======================
  // TREND (GROUP BY BULAN)
  // =======================
  void _processTrend(List<dynamic> rows) {
    final Map<String, int> grouped = {};

    for (final row in rows) {
      final date = DateTime.parse(row['created_at']);
      final label = '${date.month}/${date.year}';

      grouped[label] = (grouped[label] ?? 0) + 1;
    }

    trendData.assignAll(
      grouped.entries.map(
            (e) => PublicComplaintTrend(
          label: e.key,
          value: e.value.toDouble(),
        ),
      ),
    );
  }

  // =======================
  // UTIL
  // =======================
  double getCategoryPercentage(int value) {
    if (totalReports.value == 0) return 0;
    return value / totalReports.value;
  }
}

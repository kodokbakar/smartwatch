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
  // LOAD ALL
  // =======================
  Future<void> loadData() async {
    await Future.wait([
      _loadSummary(),
      _loadCategories(),
      _loadTrend(),
    ]);
  }

  // =======================
  // SUMMARY
  // =======================
  Future<void> _loadSummary() async {
    final rows = await _db
        .from('laporan')
        .select('status');

    totalReports.value = rows.length;
    completedCases.value =
        rows.where((e) => e['status'] == 'Selesai').length;
  }

  // =======================
  // CATEGORY (INI KUNCI)
  // =======================
  Future<void> _loadCategories() async {
    final rows = await _db
        .from('laporan')
        .select('kategori');

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
  Future<void> _loadTrend() async {
    final rows = await _db
        .from('laporan')
        .select('created_at');

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


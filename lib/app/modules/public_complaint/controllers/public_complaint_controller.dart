import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import '../models/public_complaint_models.dart';

class PublicComplaintController extends GetxController {
  final SupabaseClient _db = Supabase.instance.client;

  // GA4 instance
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

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
  final RxList<PublicComplaintTrend> trendData = <PublicComplaintTrend>[].obs;

  @override
  void onInit() {
    super.onInit();

    // GA4: catat screen aduan publik dibuka
    _analytics.logScreenView(screenName: 'public_complaint');
    _analytics.logEvent(name: 'public_complaint_open');

    loadData();
  }

  void changeTab(int index) {
    selectedTab.value = index;

    // GA4: user mengganti tab
    _analytics.logEvent(
      name: 'public_complaint_tab_change',
      parameters: {'tab_index': index},
    );

    loadData();
  }

  // =======================
  // LOAD ALL
  // =======================
  Future<void> loadData() async {
    // GA4: mulai load seluruh data dashboard aduan publik
    _analytics.logEvent(name: 'public_complaint_load_start');

    try {
      await Future.wait([
        _loadSummary(),
        _loadCategories(),
        _loadTrend(),
      ]);

      // GA4: load sukses (angka ringkas saja)
      _analytics.logEvent(
        name: 'public_complaint_load_success',
        parameters: {
          'total_reports': totalReports.value,
          'completed_cases': completedCases.value,
        },
      );
    } catch (_) {
      // GA4: load gagal (reason dibuat generik)
      _analytics.logEvent(
        name: 'public_complaint_load_failed',
        parameters: {'reason': 'exception'},
      );
      rethrow;
    }
  }

  // =======================
  // SUMMARY
  // =======================
  Future<void> _loadSummary() async {
    final rows = await _db.from('laporan').select('status');

    totalReports.value = rows.length;
    completedCases.value = rows.where((e) => e['status'] == 'Selesai').length;

    // GA4: summary selesai diproses
    _analytics.logEvent(
      name: 'public_complaint_summary_loaded',
      parameters: {
        'total_reports': totalReports.value,
        'completed_cases': completedCases.value,
      },
    );
  }

  // =======================
  // CATEGORY
  // =======================
  Future<void> _loadCategories() async {
    final rows = await _db.from('laporan').select('kategori');

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

    // GA4: kategori selesai diproses (angka agregat saja)
    _analytics.logEvent(
      name: 'public_complaint_categories_loaded',
      parameters: {
        'penyalahgunaan_wewenang': penyalahgunaanWewenang.value,
        'diskriminasi': diskriminasi.value,
        'kekerasan_berlebihan': kekerasanBerlebihan.value,
      },
    );
  }

  // =======================
  // TREND (GROUP BY BULAN)
  // =======================
  Future<void> _loadTrend() async {
    final rows = await _db.from('laporan').select('created_at');

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

    // GA4: trend selesai diproses (kirim jumlah titik data saja)
    _analytics.logEvent(
      name: 'public_complaint_trend_loaded',
      parameters: {'points': trendData.length},
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

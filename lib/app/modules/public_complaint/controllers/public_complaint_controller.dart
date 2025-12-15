import 'package:get/get.dart';

class PublicComplaintController extends GetxController {
  final selectedTab = 0.obs;

  // Statistik utama - berubah sesuai filter
  final RxInt completedCases = 0.obs;
  final RxInt totalReports = 0.obs;

  // Kategori Aduan - berubah sesuai filter
  final RxInt penyalahgunaanWewenang = 0.obs;
  final RxInt diskriminasi = 0.obs;
  final RxInt kekerasanBerlebihan = 0.obs;

  // Data untuk grafik tren - berubah sesuai filter
  final RxList<ChartData> trendData = <ChartData>[].obs;

  // Data master untuk setiap periode
  final Map<int, PeriodData> periodDataMap = {
    0: PeriodData(
      // Bulan Ini
      completedCases: 87,
      totalReports: 134,
      penyalahgunaanWewenang: 95,
      diskriminasi: 75,
      kekerasanBerlebihan: 55,
      chartData: [
        ChartData(label: 'Week 1', value: 25),
        ChartData(label: 'Week 2', value: 35),
        ChartData(label: 'Week 3', value: 42),
        ChartData(label: 'Week 4', value: 32),
      ],
    ),
    1: PeriodData(
      // 3 Bulan Terakhir
      completedCases: 287,
      totalReports: 456,
      penyalahgunaanWewenang: 88,
      diskriminasi: 70,
      kekerasanBerlebihan: 62,
      chartData: [
        ChartData(label: 'Bulan 1', value: 120),
        ChartData(label: 'Bulan 2', value: 156),
        ChartData(label: 'Bulan 3', value: 180),
      ],
    ),
    2: PeriodData(
      // Tahun Ini
      completedCases: 987,
      totalReports: 1234,
      penyalahgunaanWewenang: 80,
      diskriminasi: 65,
      kekerasanBerlebihan: 48,
      chartData: [
        ChartData(label: 'Jan', value: 80),
        ChartData(label: 'Feb', value: 95),
        ChartData(label: 'Mar', value: 120),
        ChartData(label: 'Apr', value: 110),
        ChartData(label: 'Mei', value: 130),
        ChartData(label: 'Jun', value: 145),
        ChartData(label: 'Jul', value: 125),
        ChartData(label: 'Ago', value: 140),
        ChartData(label: 'Sep', value: 155),
        ChartData(label: 'Okt', value: 150),
        ChartData(label: 'Nov', value: 160),
        ChartData(label: 'Des', value: 134),
      ],
    ),
  };

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  // Load data berdasarkan tab yang dipilih
  Future<void> loadData() async {
    await Future.delayed(Duration(milliseconds: 400));
    updateDataForTab(selectedTab.value);
  }

  // Update data ketika tab berubah
  void changeTab(int index) {
    selectedTab.value = index;
    updateDataForTab(index);
  }

  // Update semua data berdasarkan periode yang dipilih
  void updateDataForTab(int tabIndex) {
    final data = periodDataMap[tabIndex];
    if (data != null) {
      completedCases.value = data.completedCases;
      totalReports.value = data.totalReports;
      penyalahgunaanWewenang.value = data.penyalahgunaanWewenang;
      diskriminasi.value = data.diskriminasi;
      kekerasanBerlebihan.value = data.kekerasanBerlebihan;
      trendData.value = data.chartData;
    }
  }

  // Helper untuk mendapatkan persentase kategori
  double getCategoryPercentage(int categoryValue) {
    return categoryValue / 100.0;
  }

  @override
  void onClose() {
    super.onClose();
  }
}

// Model untuk data periode
class PeriodData {
  final int completedCases;
  final int totalReports;
  final int penyalahgunaanWewenang;
  final int diskriminasi;
  final int kekerasanBerlebihan;
  final List<ChartData> chartData;

  PeriodData({
    required this.completedCases,
    required this.totalReports,
    required this.penyalahgunaanWewenang,
    required this.diskriminasi,
    required this.kekerasanBerlebihan,
    required this.chartData,
  });
}

// Model untuk data chart
class ChartData {
  final String label;
  final double value;

  ChartData({
    required this.label,
    required this.value,
  });
}
import 'package:get/get.dart';

class PublicComplaintController extends GetxController {
  final selectedTab = 0.obs;
  // Statistik utama (sesuai kebutuhan UI)
  final RxInt _completedCases = 987.obs;
  final RxInt _totalReports = 1234.obs;

  // Getter yang dipanggil UI kamu
  int get completedCases => _completedCases.value;
  int get totalReports => _totalReports.value;

  // Kategori Aduan
  final RxInt penyalahgunaanWewenang = 80.obs;
  final RxInt diskriminasi = 65.obs;
  final RxInt kekerasanBerlebihan = 30.obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }

  Future<void> loadData() async {
    await Future.delayed(Duration(milliseconds: 400));
    // Data bisa di-update dari API di sini
  }

  @override
  void onClose() {
    super.onClose();
  }
}

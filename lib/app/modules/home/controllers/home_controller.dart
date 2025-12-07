import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final selectedTab = 0.obs;
  final totalKasus = 1247.obs;
  final totalLaporan = 2.obs;
  final sedangProses = 1.obs;
  final selesai = 1.obs;

  final keluhanController = TextEditingController();
  final deskripsiController = TextEditingController();

  // Monthly statistics data
  final monthlyStats = [
    {'month': 'Jul', 'value': 80.0},
    {'month': 'Agu', 'value': 60.0},
    {'month': 'Sep', 'value': 95.0},
    {'month': 'Okt', 'value': 85.0},
  ].obs;

  // Sample reports data
  final reports = [
    {
      'id': '#RPT-2025-001',
      'status': 'Selesai',
      'title': 'Dugaan Korupsi Pengadaan ATK Dinas Pendidikan',
      'description':
          'Laporan Mengenai Pengadaan alat tulis kantor dengan nilai yang tidak wajar di Dinas Pendidikan Kota Bogor',
      'date': '7 Juli 2025',
      'update': '12 Agustus 2025',
    },
    {
      'id': '#RPT-2025-002',
      'status': 'Sedang Proses',
      'title': 'Penyidikan Korupsi Pengadaan Alat Pertanian',
      'description':
          'Laporan mengenai dugaan korupsi dalam pengadaan alat pertanian di Dinas Pertanian',
      'date': '15 Juli 2025',
      'update': '20 Oktober 2025',
    },
  ].obs;

  @override
  void onClose() {
    keluhanController.dispose();
    deskripsiController.dispose();
    super.onClose();
  }

  void changeTab(int index) {
    selectedTab.value = index;
  }

  void openProfile() {
    Get.toNamed('/profile');
  }

  void createNewReport() {
    // Show bottom sheet
    Get.bottomSheet(
      _buildReportBottomSheet(),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
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
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with back button
            Row(
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back_ios, size: 20),
                  onPressed: () => Get.back(),
                  padding: EdgeInsets.zero,
                  constraints: BoxConstraints(),
                ),
                SizedBox(width: 12),
                Text(
                  'Laporan Baru',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            // Keluhan field
            Text(
              'Keluhan:',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            SizedBox(height: 8),
            TextField(
              controller: keluhanController,
              decoration: InputDecoration(
                hintText: '',
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
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
            ),
            SizedBox(height: 20),
            // Deskripsi field
            Text(
              'Deskripsi laporan:',
              style: TextStyle(fontSize: 14, color: Colors.black87),
            ),
            SizedBox(height: 8),
            TextField(
              controller: deskripsiController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: '',
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
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
            ),
            SizedBox(height: 32),
            // Simpan button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: submitReport,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade400,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Simpan',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void submitReport() {
    if (keluhanController.text.isEmpty || deskripsiController.text.isEmpty) {
      Get.snackbar(
        'Error',
        'Mohon isi semua field',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
      return;
    }

    // Success
    Get.back();
    Get.snackbar(
      'Berhasil',
      'Laporan berhasil disimpan',
      snackPosition: SnackPosition.TOP,
      backgroundColor: Colors.green.shade400,
      colorText: Colors.white,
    );

    // Clear fields
    keluhanController.clear();
    deskripsiController.clear();
  }

  void openReportDetail(Map<String, dynamic> report) {
    // Navigate to report detail page
    Get.toNamed('/report-detail', arguments: report);
  }
}

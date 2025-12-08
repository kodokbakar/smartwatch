import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/home_model.dart';

class HomeController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  final selectedTab = 0.obs;

  final totalKasus = 0.obs;
  final totalLaporan = 0.obs;
  final sedangProses = 0.obs;
  final selesai = 0.obs;

  final laporanController = TextEditingController();        // judul
  final deskripsiController = TextEditingController();      // deskripsi

  final isLoading = false.obs;
  final isSubmitting = false.obs;

  // Monthly statistics data (dummy untuk tampilan)
  final monthlyStats = [
    {'month': 'Jul', 'value': 80.0},
    {'month': 'Agu', 'value': 60.0},
    {'month': 'Sep', 'value': 95.0},
    {'month': 'Okt', 'value': 85.0},
  ].obs;

  // Laporan dari Supabase
  final laporanList = <Laporan>[].obs;

  @override
  void onInit() {
    super.onInit();
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
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat laporan: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
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

  // === UI actions ===

  void changeTab(int index) {
    selectedTab.value = index;
  }

  void openProfile() {
    Get.toNamed('/profile');
  }

  void createNewReport() {
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
            // Header with back button
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

            // Field: Laporan (judul)
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
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
            const SizedBox(height: 20),

            // Field: Deskripsi Laporan
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
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
            const SizedBox(height: 32),

            // Submit button
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

    if (judul.isEmpty || deskripsi.isEmpty) {
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

      final newLaporan =
          Laporan.fromJson(inserted as Map<String, dynamic>);
      laporanList.insert(0, newLaporan);

      totalLaporan.value++;
      totalKasus.value++;
      sedangProses.value++;

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
    Get.toNamed('/report-detail', arguments: laporan);
  }
}

import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ReportController extends GetxController {
  // Observable list untuk aktivitas distribusi
  final RxList<ActivityModel> activities = <ActivityModel>[].obs;

  // Observable untuk summary data
  final RxString totalAnggaran = 'Rp. 0'.obs;
  final RxString totalRealisasi = 'Rp. 0'.obs;
  final RxInt totalProyek = 0.obs;
  final RxString totalDana = 'Rp. 0'.obs;

  // Loading state
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDashboardData();
  }

  // Fungsi untuk load data dashboard
  Future<void> loadDashboardData() async {
    try {
      isLoading.value = true;

      // Simulasi fetch data dari API
      // TODO: Ganti dengan API call sebenarnya
      await Future.delayed(Duration(seconds: 1));

      // Set summary data
      totalAnggaran.value = 'Rp. 2.5 T';
      totalRealisasi.value = 'Rp. 1.9 T';
      totalProyek.value = 125;
      totalDana.value = 'Rp. 1.2 M';

      // Set activities data
      activities.value = [
        ActivityModel(
          id: 1,
          status: 'Selesai',
          totalDana: 'Rp 150.000.000',
          namaProyek: 'Jalan',
          progress: 100,
        ),
        ActivityModel(
          id: 2,
          status: 'Berjalan',
          totalDana: 'Rp 85.000.000',
          namaProyek: 'Jembatan',
          progress: 80,
        ),
        ActivityModel(
          id: 3,
          status: 'Tertunda',
          totalDana: 'Rp 210.000.000',
          namaProyek: 'Lampu Jalan',
          progress: 0,
        ),
      ];
    } catch (e) {
      Get.snackbar(
        'Error',
        'Gagal memuat data: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Fungsi untuk refresh data (Pull to refresh)
  Future<void> refreshDashboard() async {
    await loadDashboardData();
  }

  // Fungsi untuk handle klik activity card
  void onActivityTapped(ActivityModel activity) {
    // Navigate ke detail page atau show dialog
    Get.snackbar(
      'Detail Proyek',
      'Proyek: ${activity.namaProyek}\nStatus: ${activity.status}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.shade100,
      colorText: Colors.blue.shade900,
      duration: Duration(seconds: 2),
    );

    // TODO: Navigate ke halaman detail
    // Get.toNamed(Routes.PROJECT_DETAIL, arguments: activity.id);
  }

  @override
  void onClose() {
    // Cleanup jika diperlukan
    super.onClose();
  }
}

// Model class
class ActivityModel {
  final int? id;
  final String status;
  final String totalDana;
  final String namaProyek;
  final double progress;

  ActivityModel({
    this.id,
    required this.status,
    required this.totalDana,
    required this.namaProyek,
    required this.progress,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'],
      status: json['status'] ?? '',
      totalDana: json['total_dana'] ?? '',
      namaProyek: json['nama_proyek'] ?? '',
      progress: (json['progress'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'total_dana': totalDana,
      'nama_proyek': namaProyek,
      'progress': progress,
    };
  }
}

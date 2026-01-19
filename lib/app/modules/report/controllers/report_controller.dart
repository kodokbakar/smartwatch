import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class ReportController extends GetxController {
  // Observable list untuk aktivitas distribusi
  final RxList<ActivityModel> activities = <ActivityModel>[].obs;

  // Observable untuk summary data
  final RxString totalAnggaran = 'Rp. 0'.obs;
  final RxString totalRealisasi = 'Rp. 0'.obs;
  final RxInt totalProyek = 0.obs;
  final RxInt totalDistribusi = 0.obs;

  // Loading state
  final RxBool isLoading = false.obs;

  // Instance GA4
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  @override
  void onInit() {
    super.onInit();

    // GA4: catat screen report dibuka
    _analytics.logScreenView(screenName: 'report');
    _analytics.logEvent(name: 'report_open');

    loadDashboardData();
  }

  // Fungsi untuk load data dashboard
  Future<void> loadDashboardData() async {
    isLoading.value = true;

    // GA4: mulai load data
    _analytics.logEvent(name: 'report_data_load_start');

    try {
      // Simulasi fetch data dari API
      // TODO: Ganti dengan API call sebenarnya
      await Future.delayed(const Duration(seconds: 1));

      // Set summary data
      totalAnggaran.value = 'Rp. 2.5 T';
      totalRealisasi.value = 'Rp. 1.9 T';
      totalProyek.value = 9;
      totalDistribusi.value = 2;

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

      // GA4: load sukses (kirim angka ringkas saja)
      _analytics.logEvent(
        name: 'report_data_load_success',
        parameters: {
          'total_proyek': totalProyek.value,
          'total_distribusi': totalDistribusi.value,
        },
      );
    } catch (e) {
      // GA4: load gagal (reason dibuat generik)
      _analytics.logEvent(
        name: 'report_data_load_failed',
        parameters: {'reason': 'exception'},
      );

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
    // GA4: user melakukan refresh
    _analytics.logEvent(name: 'report_refresh');

    await loadDashboardData();
  }

  // Fungsi untuk handle klik activity card
  void onActivityTapped(ActivityModel activity) {
    // GA4: user tap activity
    // Hindari kirim nama proyek. Cukup status/progress saja.
    _analytics.logEvent(
      name: 'report_activity_tap',
      parameters: {
        'status': activity.status,
        'progress': activity.progress, // double/int aman
        'has_id': activity.id == null ? 0 : 1,
      },
    );

    // UI feedback
    Get.snackbar(
      'Detail Proyek',
      'Proyek: ${activity.namaProyek}\nStatus: ${activity.status}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.shade100,
      colorText: Colors.blue.shade900,
      duration: const Duration(seconds: 2),
    );

    // TODO: Navigate ke halaman detail
    // Get.toNamed(Routes.PROJECT_DETAIL, arguments: activity.id);
  }

  @override
  void onClose() {
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

import 'package:get/get.dart';
import 'package:flutter/material.dart';

class Page3Controller extends GetxController {
  // Top statistics
  final RxInt laporanAktif = 247.obs;
  final RxInt dalamAntrean = 89.obs;
  final RxInt tingkatRespons = 92.obs;

  // Bottom statistics
  final RxInt totalLaporan = 5.obs;
  final RxInt ditinjau = 1.obs;
  final RxInt ditindaklanjuti = 1.obs;
  final RxInt selesai = 1.obs;

  // Reports list
  final RxList<ReportModel> reports = <ReportModel>[
    ReportModel(
      id: 1,
      title: 'Keterlambatan Proyek Jalan Raya Sudirman',
      description:
      'Proyek senilai Rp 15 miliar mengalami keterlambatan 3 bulan karena perizinan yang lambat',
      status: 'Ditinjau',
      timeAgo: '2 jam yang lalu',
    ),
    ReportModel(
      id: 2,
      title: 'Kualitas Material Gedung Sekolah Meragukan',
      description:
      'Penggunaan material di Dewan sekolah pada pembangunan SDN 03, Jakarta Timur perlu diperiksa',
      status: 'Ditindaklanjuti',
      timeAgo: '5 jam yang lalu',
    ),
    ReportModel(
      id: 3,
      title: 'Transparansi Anggaran Puskesmas Tanjung',
      description:
      'Anggaran renovasi Puskesmas belum terpublikasi dengan jelas untuk membangun fasilitas kesehatan',
      status: 'Selesai',
      timeAgo: '1 hari yang lalu',
    ),
  ].obs;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  // Load data
  Future<void> loadData() async {
    // Simulasi fetch data dari API
    await Future.delayed(Duration(milliseconds: 500));
    // Data sudah diset di constructor
  }

  // Open report detail
  void openReportDetail(ReportModel report) {
    Get.snackbar(
      'Detail Laporan',
      report.title,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.blue.shade100,
      colorText: Colors.blue.shade900,
      duration: Duration(seconds: 2),
    );

    // TODO: Navigate ke detail page
    // Get.toNamed(Routes.REPORT_DETAIL, arguments: report.id);
  }

  @override
  void onClose() {
    super.onClose();
  }
}

// Report Model
class ReportModel {
  final int id;
  final String title;
  final String description;
  final String status;
  final String timeAgo;

  ReportModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.timeAgo,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'],
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? '',
      timeAgo: json['time_ago'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'status': status,
      'time_ago': timeAgo,
    };
  }
}
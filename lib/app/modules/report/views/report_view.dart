import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/report_controller.dart';
import '../../../widgets/app_drawer.dart';

class ReportView extends GetView<ReportController> {
  const ReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black87),
          onPressed: () {
            showGeneralDialog(
              context: context,
              barrierDismissible: true,
              barrierLabel:
              MaterialLocalizations.of(context).modalBarrierDismissLabel,
              barrierColor: Colors.black54,
              transitionDuration: const Duration(milliseconds: 300),
              pageBuilder: (context, animation, secondaryAnimation) {
                return const Align(
                  alignment: Alignment.centerLeft,
                  child: AppDrawer(),
                );
              },
              transitionBuilder:
                  (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: const Offset(-1, 0),
                    end: Offset.zero,
                  ).animate(animation),
                  child: child,
                );
              },
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.account_circle_outlined, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.activities.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF6C5CE7)),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refreshDashboard,
          color: const Color(0xFF6C5CE7),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // =======================
                  // SUMMARY CARDS
                  // =======================
                  Obx(
                        () => GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.4,
                      children: [
                        _buildSummaryCard(
                          'Total Anggaran Dikeluarkan',
                          controller.totalAnggaran.value,
                          const Color(0xFF6C5CE7),
                        ),
                        _buildSummaryCard(
                          'Total Realisasi',
                          controller.totalRealisasi.value,
                          const Color(0xFF6C5CE7),
                        ),
                        _buildSummaryCard(
                          'Total Proyek',
                          controller.totalProyek.value.toString(),
                          const Color(0xFF8B7EF7),
                        ),
                        _buildSummaryCard(
                          'Total Distribusi Realisasi Proyek',
                          controller.totalDistribusi.value.toString(),
                          const Color(0xFF8B7EF7),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // =======================
                  // ACTIVITY TITLE
                  // =======================
                  const Text(
                    'Aktivitas Distribusi Terkini',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // =======================
                  // ACTIVITY LIST
                  // =======================
                  Obx(() {
                    if (controller.activities.isEmpty) {
                      return Container(
                        padding: const EdgeInsets.all(40),
                        child: Center(
                          child: Column(
                            children: [
                              Icon(
                                Icons.inventory_2_outlined,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Tidak ada aktivitas',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.activities.length,
                      separatorBuilder: (context, index) =>
                      const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final activity = controller.activities[index];
                        return _buildActivityCard(activity);
                      },
                    );
                  }),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // =======================
  // SUMMARY CARD
  // =======================
  Widget _buildSummaryCard(
      String title,
      String value,
      Color color,
      ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // =======================
  // ACTIVITY CARD
  // =======================
  Widget _buildActivityCard(ActivityModel activity) {
    Color statusColor;

    switch (activity.status) {
      case 'Selesai':
        statusColor = const Color(0xFF00D25B);
        break;
      case 'Berjalan':
        statusColor = const Color(0xFF3B82F6);
        break;
      case 'Tertunda':
        statusColor = const Color(0xFFFF6B6B);
        break;
      default:
        statusColor = Colors.grey;
    }

    return GestureDetector(
      onTap: () => controller.onActivityTapped(activity),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  activity.status,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Dana',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Nama Proyek',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      activity.totalDana,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activity.namaProyek,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: activity.progress / 100,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                minHeight: 8,
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '${activity.progress.toInt()}% Selesai',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
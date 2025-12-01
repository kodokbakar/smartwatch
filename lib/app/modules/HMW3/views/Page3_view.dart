import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/page3_controller.dart';

class Page3View extends GetView<Page3Controller> {
  const Page3View({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.black87),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle_outlined, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Statistics Cards
              Obx(
                    () => Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        value: controller.laporanAktif.value.toString(),
                        label: 'Laporan Aktif',
                        color: Colors.blue.shade100,
                        textColor: Colors.blue.shade700,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        value: controller.dalamAntrean.value.toString(),
                        label: 'Dalam Antrean',
                        color: Colors.orange.shade100,
                        textColor: Colors.orange.shade700,
                      ),
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        value: '${controller.tingkatRespons.value}%',
                        label: 'Tingkat Respons',
                        color: Colors.green.shade100,
                        textColor: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              // Laporan Terbaru Section
              Text(
                'Laporan Terbaru',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16),

              // Reports List
              Obx(
                    () => ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: controller.reports.length,
                  separatorBuilder: (context, index) => SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final report = controller.reports[index];
                    return _buildReportCard(report);
                  },
                ),
              ),
              SizedBox(height: 24),

              // Statistik Laporan Anda
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Statistik Laporan Anda',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 20),
                    Obx(
                          () => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildBottomStatItem(
                            value: controller.totalLaporan.value.toString(),
                            label: 'Total',
                          ),
                          _buildBottomStatItem(
                            value: controller.ditinjau.value.toString(),
                            label: 'Ditinjau',
                          ),
                          _buildBottomStatItem(
                            value: controller.ditindaklanjuti.value.toString(),
                            label: 'Ditindaklanjuti',
                          ),
                          _buildBottomStatItem(
                            value: controller.selesai.value.toString(),
                            label: 'Selesai',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String value,
    required String label,
    required Color color,
    required Color textColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportCard(ReportModel report) {
    Color iconBgColor;
    Color iconColor;
    Color badgeColor;
    Color badgeTextColor;
    IconData iconData;

    switch (report.status) {
      case 'Ditinjau':
        iconBgColor = Colors.orange.shade100;
        iconColor = Colors.orange.shade700;
        badgeColor = Colors.yellow.shade600;
        badgeTextColor = Colors.white;
        iconData = Icons.warning_amber_rounded;
        break;
      case 'Ditindaklanjuti':
        iconBgColor = Colors.blue.shade100;
        iconColor = Colors.blue.shade700;
        badgeColor = Colors.blue.shade600;
        badgeTextColor = Colors.white;
        iconData = Icons.info_outline;
        break;
      case 'Selesai':
        iconBgColor = Colors.green.shade100;
        iconColor = Colors.green.shade700;
        badgeColor = Colors.green.shade600;
        badgeTextColor = Colors.white;
        iconData = Icons.check_circle_outline;
        break;
      default:
        iconBgColor = Colors.grey.shade100;
        iconColor = Colors.grey.shade700;
        badgeColor = Colors.grey.shade600;
        badgeTextColor = Colors.white;
        iconData = Icons.description_outlined;
    }

    return GestureDetector(
      onTap: () => controller.openReportDetail(report),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconData,
                color: iconColor,
                size: 24,
              ),
            ),
            SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    report.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        report.timeAgo,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: badgeColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          report.status,
                          style: TextStyle(
                            fontSize: 11,
                            color: badgeTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomStatItem({
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }
}
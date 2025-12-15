import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/public_complaint_controller.dart';
import '../../../widgets/app_drawer.dart';

class PublicComplaintView extends GetView<PublicComplaintController> {
  const PublicComplaintView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.black87),
          onPressed: () {
            showGeneralDialog(
              context: context,
              barrierDismissible: true,
              barrierLabel: MaterialLocalizations.of(
                context,
              ).modalBarrierDismissLabel,
              barrierColor: Colors.black54,
              transitionDuration: Duration(milliseconds: 300),
              pageBuilder: (context, animation, secondaryAnimation) {
                return Align(
                  alignment: Alignment.centerLeft,
                  child: AppDrawer(),
                );
              },
              transitionBuilder:
                  (context, animation, secondaryAnimation, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(-1, 0),
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
            icon: Icon(
              Icons.account_circle_outlined,
              color: Colors.black87,
              size: 28,
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ============================
              // TOP FILTER (BULAN INI / 3 BULAN / TAHUN)
              // ============================
              SizedBox(height: 16),
              Obx(
                    () => Container(
                  padding: EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: [
                      Expanded(child: _buildTabButton('Bulan Ini', 0)),
                      Expanded(child: _buildTabButton('3 Bulan Terakhir', 1)),
                      Expanded(child: _buildTabButton('Tahun Ini', 2)),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 20),
              // ============================
              // TOP PURPLE CARDS
              // ============================
              Obx(
                    () => Row(
                  children: [
                    Expanded(
                      child: _purpleCard(
                        title: "Kasus Selesai",
                        value: controller.completedCases.value.toString(),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _purpleCard(
                        title: "Total Aduan Publik",
                        value: controller.totalReports.value.toString(),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24),

              // ============================
              // CATEGORY SECTION
              // ============================
              Text(
                "Aduan Berdasarkan Kategori",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),

              SizedBox(height: 12),

              _categoryCard(),

              SizedBox(height: 28),

              // ============================
              // TRANSPARENCY TREND
              // ============================
              Text(
                "Tren Transparansi",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),

              SizedBox(height: 12),

              _trendChart(),

              SizedBox(height: 28),

              // ============================
              // STATUS PENYELESAIAN
              // ============================
              Text(
                "Status Penyelesaian Kasus",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),

              SizedBox(height: 12),

              Obx(
                    () => _statusCard(
                  controller.completedCases.value.toString(),
                ),
              ),

              SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // ============================
  // FILTER BUTTONS
  // ============================
  Widget _buildTabButton(String label, int index) {
    final isSelected = controller.selectedTab.value == index;
    return GestureDetector(
      onTap: () => controller.changeTab(index),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isSelected ? Colors.blue.shade700 : Colors.grey.shade600,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  // ============================
  // PURPLE CARD (TOP SUMMARY)
  // ============================
  Widget _purpleCard({required String title, required String value}) {
    return Container(
      height: 150,
      decoration: BoxDecoration(
        color: Color(0xFF6A3DF6),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.deepPurple.withOpacity(0.25),
            blurRadius: 10,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 42,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================
  // CATEGORY CARD
  // ============================
  Widget _categoryCard() {
    return Obx(
          () => Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.08),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            _categoryItem(
              "Penyalahgunaan Wewenang",
              Colors.blue,
              controller.getCategoryPercentage(
                  controller.penyalahgunaanWewenang.value),
              controller.penyalahgunaanWewenang.value,
            ),
            SizedBox(height: 18),
            _categoryItem(
              "Diskriminasi",
              Colors.green,
              controller.getCategoryPercentage(controller.diskriminasi.value),
              controller.diskriminasi.value,
            ),
            SizedBox(height: 18),
            _categoryItem(
              "Kekerasan Berlebihan",
              Colors.red,
              controller.getCategoryPercentage(
                  controller.kekerasanBerlebihan.value),
              controller.kekerasanBerlebihan.value,
            ),
          ],
        ),
      ),
    );
  }

  Widget _categoryItem(String label, Color color, double value, int count) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            Text(
              '$count kasus',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 10,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }

  // ============================
  // TREND CHART
  // ============================
  Widget _trendChart() {
    return Obx(
          () => Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.08),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Chart
            SizedBox(
              height: 200,
              child: controller.trendData.isEmpty
                  ? Center(
                child: Text(
                  'Tidak ada data',
                  style: TextStyle(color: Colors.grey.shade400),
                ),
              )
                  : Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: controller.trendData.map((data) {
                  // Calculate max value for scaling
                  final maxValue = controller.trendData
                      .map((e) => e.value)
                      .reduce((a, b) => a > b ? a : b);

                  return _buildBar(
                    data.label,
                    data.value,
                    maxValue,
                    130, // max height for bar
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(String label, double value, double maxValue, double maxHeight) {
    final height = (value / maxValue) * maxHeight;
    final isYearly = controller.selectedTab.value == 2;

    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: isYearly ? 1 : 4),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Value label
            Text(
              value.toInt().toString(),
              style: TextStyle(
                fontSize: isYearly ? 9 : 11,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            SizedBox(height: 2),
            // Bar
            Container(
              width: double.infinity,
              height: height,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF5F33E1), Color(0xFF8B7EF7)],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            SizedBox(height: 4),
            // Label
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: isYearly ? 8 : 10,
                color: Colors.grey.shade600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ============================
  // STATUS CARD
  // ============================
  Widget _statusCard(String total) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.symmetric(vertical: 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.08),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            total,
            style: TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "Total Kasus Selesai",
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}
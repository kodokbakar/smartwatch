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
        child: Column(
          children: [
            // ============================
            // TOP FILTER (BULAN INI / 3 BULAN / TAHUN)
            // ============================
            SizedBox(height: 10),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: _purpleCard(
                      title: "Kasus Selesai",
                      value: controller.completedCases.toString(),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: _purpleCard(
                      title: "Total Aduan Publik",
                      value: controller.totalReports.toString(),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // ============================
            // CATEGORY SECTION
            // ============================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Aduan Berdasarkan Kategori",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),

            SizedBox(height: 12),

            _categoryCard(),

            SizedBox(height: 28),

            // ============================
            // TRANSPARENCY TREND
            // ============================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Tren Transparansi",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),

            SizedBox(height: 12),

            _chartPlaceholder(),

            SizedBox(height: 28),

            // ============================
            // STATUS PENYELESAIAN
            // ============================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Status Penyelesaian Kasus",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
              ),
            ),

            SizedBox(height: 12),

            _statusCard(controller.completedCases.toString()),

            SizedBox(height: 30),
          ],
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
        padding: EdgeInsets.symmetric(vertical: 5),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(22),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
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
            // flexible + fittedbox prevents overflow with large text or accessibility font scaling
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.center,
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
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
            _categoryItem("Penyalahgunaan Wewenang", Colors.blue, 0.95),
            SizedBox(height: 18),
            _categoryItem("Diskriminasi", Colors.green, 0.75),
            SizedBox(height: 18),
            _categoryItem("Kekerasan Berlebihan", Colors.red, 0.55),
          ],
        ),
      ),
    );
  }

  Widget _categoryItem(String label, Color color, double value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
  // CHART PLACEHOLDER
  // ============================
  Widget _chartPlaceholder() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 190,
        decoration: BoxDecoration(
          color: Color(0xffe8f1ff),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.08),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            "Chart Placeholder",
            style: TextStyle(color: Colors.black38),
          ),
        ),
      ),
    );
  }

  // ============================
  // STATUS CARD
  // ============================
  Widget _statusCard(String total) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
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
              "Total Kasus",
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }
}

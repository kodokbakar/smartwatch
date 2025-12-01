import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/Page4_controller.dart';

class Page4View extends GetView<Page4Controller> {
  const Page4View({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.black87, size: 28),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.account_circle_outlined, color: Colors.black87, size: 28),
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Row(
                  children: [
                    _filterItem("Bulan Ini", true),
                    _filterItem("3 Bulan Terakhir", false),
                    _filterItem("Tahun Ini", false),
                  ],
                ),
              ),
            ),

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
  Widget _filterItem(String text, bool active) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        alignment: Alignment.center,
        child: Text(
          text,
          style: TextStyle(
            color: active ? Colors.blue : Colors.black54,
            fontWeight: FontWeight.w600,
            fontSize: 14,
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
              style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            // flexible + fittedbox prevents overflow with large text or accessibility font scaling
            Flexible(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold),
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
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 10,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation(color),
          ),
        )
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
              style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            SizedBox(height: 10),
            Text("Total Kasus", style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}

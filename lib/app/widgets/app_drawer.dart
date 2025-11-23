import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final currentRoute = Get.currentRoute;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: screenWidth * 0.55,
        height: screenHeight,
        decoration: BoxDecoration(color: Colors.white),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.arrow_back_ios, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                      padding: EdgeInsets.zero,
                      constraints: BoxConstraints(),
                    ),
                  ],
                ),
              ),
              // Welcome text
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Welcome, ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          'Udin',
                          style: TextStyle(fontSize: 16, color: Colors.black87),
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Container(
                      width: 250,
                      height: 1,
                      color: Colors.grey.shade300,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              // Menu Items
              _buildMenuItem(
                title: 'Dashboard',
                isActive: currentRoute == '/home',
                onTap: () {
                  Navigator.of(context).pop();
                  Get.offAllNamed('/home');
                },
              ),
              _buildMenuItem(
                title: 'Laporan',
                isActive: currentRoute == '/laporan',
                onTap: () {
                  Navigator.of(context).pop();
                  // Navigate to laporan page
                },
              ),
              _buildMenuItem(
                title: 'Aktivitas Distribusi',
                isActive: currentRoute == '/aktivitas-distribusi',
                onTap: () {
                  Navigator.of(context).pop();
                  // Navigate to aktivitas distribusi page
                },
              ),
              _buildMenuItem(
                title: 'Aduan Publik',
                isActive: currentRoute == '/aduan-publik',
                onTap: () {
                  Navigator.of(context).pop();
                  // Navigate to aduan publik page
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
        child: Center(
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: Colors.black87,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w300,
            ),
          ),
        ),
      ),
    );
  }
}

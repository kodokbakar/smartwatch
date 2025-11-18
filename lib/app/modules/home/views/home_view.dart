import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Page'), // Judul halaman
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              // Command: pindah ke halaman Settings
              Get.toNamed('/settings');
            },
            icon: const Icon(Icons.settings),
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Command: Menampilkan teks selamat datang
            const Text(
              'Selamat datang di HomeView',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            // Command: Tombol navigasi ke halaman Profile
            ElevatedButton(
              onPressed: () {
                Get.toNamed('/profile');
              },
              child: const Text('Pergi ke Profile'),
            ),

            const SizedBox(height: 10),

            // Command: Tombol navigasi ke halaman Detail dengan parameter
            ElevatedButton(
              onPressed: () {
                Get.toNamed('/detail/123'); // dummy id
              },
              child: const Text('Lihat Detail Item'),
            ),

            const SizedBox(height: 10),

            // Command: Menggunakan controller (dummy count)
            Obx(() => Text(
              'Counter: ${controller.counter.value}',
              style: const TextStyle(fontSize: 16),
            )
            ),

            const SizedBox(height: 10),

            // Command: Tombol increment counter
            ElevatedButton(
              onPressed: () {
                controller.increment(); // fungsi dummy dari controller
              },
              child: const Text('Tambah Counter'),
            ),
          ],
        ),
      ),
    );
  }
}

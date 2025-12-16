import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart'; // <-- tambah

import '../controllers/profile_detail_controller.dart';

class ProfileDetailView extends GetView<ProfileDetailController> {
  const ProfileDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    InputDecoration _squareFieldDecoration({
      required String label,
      required String hint,
      Widget? prefixIcon,
    }) {
      return InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon,
        isDense: true,
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.green.shade600, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      );
    }

    Widget _sectionCard({required Widget child}) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: child,
      );
    }

    /// Renderer avatar SVG yang reusable.
    /// Menangani kondisi svg kosong (mis. sebelum data profil selesai dimuat).
    Widget _avatarSvg({required String svg, required double size}) {
      if (svg.trim().isEmpty) {
        return SizedBox(
          width: size,
          height: size,
          child: Icon(
            Icons.person_outline,
            color: Colors.grey.shade600,
            size: size * 0.55,
          ),
        );
      }

      return SvgPicture.string(
        svg,
        width: size,
        height: size,
        fit: BoxFit.cover,
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Tentang Profil',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          final isLoading = controller.isLoading.value;
          final error = controller.errorMessage.value;
          final user = controller.user.value;

          if (isLoading && user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (error != null && user == null) {
            return Center(
              child: Text(
                error,
                style: theme.textTheme.bodyMedium?.copyWith(color: Colors.red),
                textAlign: TextAlign.center,
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 24),

              // Avatar minidenticon berbasis username (konsisten dengan ProfileView).
              Center(
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.grey.shade200,
                  child: ClipOval(
                    child: _avatarSvg(
                      svg: controller.avatarSvg.value,
                      size: 96,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: _sectionCard(
                  child: Column(
                    children: [
                      TextField(
                        controller: controller.nameController,
                        textInputAction: TextInputAction.next,
                        decoration: _squareFieldDecoration(
                          label: 'Nama',
                          hint: 'Masukkan nama lengkap',
                          prefixIcon: const Icon(Icons.badge_outlined),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: controller.usernameController,
                        textInputAction: TextInputAction.done,
                        decoration: _squareFieldDecoration(
                          label: 'Username',
                          hint: 'Masukkan username',
                          prefixIcon: const Icon(Icons.alternate_email),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Row(
                          children: [
                            Text(
                              'Status',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: Text(
                                'User',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: Colors.grey.shade800,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 32),
                child: Obx(() {
                  final isUpdating = controller.isUpdating.value;

                  return GestureDetector(
                    onTap: isUpdating ? null : controller.updateProfile,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.green),
                      ),
                      child: Center(
                        child: isUpdating
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(
                                'Update',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  color: Colors.green,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          );
        }),
      ),
    );
  }
}

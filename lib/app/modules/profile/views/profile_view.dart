import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart'; 

import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Obx(() {
          final isLoading = controller.isLoading.value;
          final error = controller.errorMessage.value;
          final user = controller.user.value;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Back arrow
              Padding(
                padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Get.back(),
                ),
              ),

              if (isLoading && user == null) ...[
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                ),
              ] else if (error != null && user == null) ...[
                Expanded(
                  child: Center(
                    child: Text(
                      error,
                      style: theme.textTheme.bodyMedium
                          ?.copyWith(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ] else ...[
                // Header: avatar + name + email
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    children: [
                      /// Avatar hasil generate dari username (minidenticon).
                      /// View hanya bertugas merender string SVG dari controller.
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.grey.shade200,
                        child: ClipOval(
                          child: _AvatarSvg(
                            svg: controller.avatarSvg.value,
                            size: 72,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user?.displayName ?? 'Pengguna',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              user?.email ?? 'email@example.com',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                const Divider(height: 1),

                _ProfileMenuItem(
                  icon: Icons.badge_outlined,
                  label: 'Tentang Profil',
                  onTap: controller.goToProfileDetail,
                ),
                const Divider(height: 1),
                _ProfileMenuItem(
                  icon: Icons.help_outline,
                  label: 'Bantuan',
                  onTap: controller.goToHelp,
                ),
                const Divider(height: 1),
                _ProfileMenuItem(
                  icon: Icons.info_outline,
                  label: 'Tentang Aplikasi',
                  onTap: controller.goToAboutApp,
                ),
                const Divider(height: 1),

                const Spacer(),

                // Logout button
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  child: GestureDetector(
                    onTap: controller.logout,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.red),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.logout, color: Colors.red),
                          const SizedBox(width: 8),
                          Text(
                            'Log Out',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.red,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          );
        }),
      ),
    );
  }
}

/// Widget kecil agar file view tetap rapi.
/// Menangani fallback ketika svg masih kosong (mis. loading).
class _AvatarSvg extends StatelessWidget {
  final String svg;
  final double size;

  const _AvatarSvg({
    required this.svg,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
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
}


class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding:
        const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Row(
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

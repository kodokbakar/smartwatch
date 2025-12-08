import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/profile_detail_controller.dart';

class ProfileDetailView extends GetView<ProfileDetailController> {
  const ProfileDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
        child: Obx(
          () {
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
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),

                // Avatar di tengah
                Center(
                  child: CircleAvatar(
                    radius: 48,
                    backgroundImage: const NetworkImage(
                      'https://placehold.co/400',
                    ),
                    backgroundColor: Colors.grey.shade200,
                  ),
                ),

                const SizedBox(height: 48),

                // NAMA (editable)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Nama :',
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: controller.nameController,
                          decoration: const InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            hintText: 'Nama',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // USERNAME (editable)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Username :',
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: controller.usernameController,
                          decoration: const InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            hintText: 'Username',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                // STATUS (hanya User, tidak bisa diubah)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Status :',
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'User',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),

                const Spacer(),

                // Tombol Update
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: Obx(
                    () {
                      final isUpdating = controller.isUpdating.value;

                      return GestureDetector(
                        onTap: isUpdating
                            ? null
                            : controller.updateProfile,
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
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'Update',
                                    style: theme
                                        .textTheme.titleMedium
                                        ?.copyWith(
                                      color: Colors.green,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

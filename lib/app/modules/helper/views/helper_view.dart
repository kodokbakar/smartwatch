import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/helper_controller.dart';

class HelperView extends GetView<HelperController> {
  const HelperView({super.key});

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
          'Bantuan',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: SafeArea(
        child: Obx(
          () {
            final isLoadingUser = controller.isLoadingUser.value;
            final error = controller.errorMessage.value;
            final user = controller.user.value;

            if (isLoadingUser && user == null) {
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

            final emailText = user?.email ?? '@gmail.com';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 32),

                // Icon telepon + orang di tengah
                Center(
                  child: Icon(
                    Icons.support_agent_outlined,
                    size: 72,
                    color: Colors.black87,
                  ),
                ),

                const SizedBox(height: 64),

                // Email
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24.0),
                  child: RichText(
                    text: TextSpan(
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.black87,
                      ),
                      children: [
                        const TextSpan(text: 'Email: '),
                        TextSpan(
                          text: emailText,
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                const Divider(height: 1),

                // Laporkan Permasalahan
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                  child: Text(
                    'Laporkan Permasalahan',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: TextField(
                    controller: controller.messageController,
                    maxLines: 5,
                    minLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Isi Permasalahan ..',
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                const Divider(height: 1),

                const Spacer(),

                // Tombol Kirim hijau
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(24, 0, 24, 32),
                  child: Obx(
                    () {
                      final isSending = controller.isSending.value;

                      return GestureDetector(
                        onTap:
                            isSending ? null : controller.sendHelpRequest,
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
                            child: isSending
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.mail_outline,
                                        color: Colors.green,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Kirim',
                                        style: theme
                                            .textTheme.titleMedium
                                            ?.copyWith(
                                          color: Colors.green,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
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

import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart'; 

import '../../../data/models/user_model.dart';

class ProfileController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  final user = Rxn<AppUser>();
  final isLoading = false.obs;
  final errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final authUser = _supabase.auth.currentUser;

      if (authUser == null) {
        errorMessage.value = 'User not logged in';
        isLoading.value = false;
        return;
      }

      final data = await _supabase
          .from('user') // table: public.user
          .select()
          .eq('id', authUser.id)
          .maybeSingle();

      if (data == null) {
        errorMessage.value = 'Profile data not found';
      } else {
        user.value = AppUser.fromJson(data);
      }
    } catch (e) {
      errorMessage.value = 'Failed to load profile: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    try {
      await _supabase.auth.signOut();
      Get.toNamed('/login');
    } catch (e) {
      Get.snackbar('Logout Failed', e.toString());
    }
  }

  void goToProfileDetail() {  
    Get.toNamed('/profile-detail');
  }

  void goToHelp() {
    Get.toNamed('/helper');
  }

  void goToAboutApp() {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: SizedBox(
          width: Get.width * 0.85, // popup lebih besar
          height: 260,             // tinggi lebih besar
          child: Stack(
            children: [
              // Konten utama dialog
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),

                    Center(
                      child: Text(
                        'SmartWatch',
                        style: Get.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 12),

                    const Center(
                      child: Text(
                        'Aplikasi dari rakyat untuk rakyat',
                        textAlign: TextAlign.center,
                      ),
                    ),

                    const Spacer(),

                    Center(
                      child: Text(
                        'Versi 1.0.0',
                        style: Get.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),

              // Tombol X di pojok kanan atas popup
              Positioned(
                right: 0,
                top: 0,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Get.back(),
                  splashRadius: 20,
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

}

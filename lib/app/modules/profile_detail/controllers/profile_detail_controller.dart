import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../data/models/user_model.dart';

class ProfileDetailController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  final user = Rxn<AppUser>();
  final isLoading = false.obs;
  final isUpdating = false.obs;
  final errorMessage = RxnString();

  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    isLoading.value = true;
    errorMessage.value = null;

    try {
      final authUser = _supabase.auth.currentUser;
      if (authUser == null) {
        errorMessage.value = 'User belum login';
        return;
      }

      final data = await _supabase
          .from('user')
          .select()
          .eq('id', authUser.id)
          .maybeSingle();

      if (data == null) {
        errorMessage.value = 'Data profil tidak ditemukan';
      } else {
        final appUser = AppUser.fromJson(data);
        user.value = appUser;
        nameController.text = appUser.fullName ?? '';
        usernameController.text = appUser.username;
      }
    } catch (e) {
      errorMessage.value = 'Gagal memuat profil: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateProfile() async {
    final currentUser = user.value;
    if (currentUser == null) return;

    final fullName = nameController.text.trim();
    final username = usernameController.text.trim();

    if (username.isEmpty) {
      Get.snackbar('Validasi', 'Username tidak boleh kosong.');
      return;
    }

    try {
      isUpdating.value = true;

      await _supabase
          .from('user')
          .update({
            'full_name': fullName.isEmpty ? null : fullName,
            'username': username,
          })
          .eq('id', currentUser.id);

      // perbarui state lokal
      user.value = AppUser(
        id: currentUser.id,
        email: currentUser.email,
        username: username,
        fullName: fullName.isEmpty ? null : fullName,
        createdAt: currentUser.createdAt,
      );

      Get.snackbar('Berhasil', 'Profil berhasil diperbarui.');
    } catch (e) {
      Get.snackbar('Gagal', 'Tidak dapat memperbarui profil: $e');
    } finally {
      isUpdating.value = false;
    }
  }

  @override
  void onClose() {
    nameController.dispose();
    usernameController.dispose();
    super.onClose();
  }
}

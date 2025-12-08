import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../data/models/user_model.dart';

class HelperController extends GetxController {
  final SupabaseClient _supabase = Supabase.instance.client;

  final user = Rxn<AppUser>();
  final isLoadingUser = false.obs;
  final isSending = false.obs;
  final errorMessage = RxnString();

  final TextEditingController messageController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _loadUser();
  }

  Future<void> _loadUser() async {
    isLoadingUser.value = true;
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
        user.value = AppUser.fromJson(data);
      }
    } catch (e) {
      errorMessage.value = 'Gagal memuat profil: $e';
    } finally {
      isLoadingUser.value = false;
    }
  }

  Future<void> sendHelpRequest() async {
    final text = messageController.text.trim();

    if (text.isEmpty) {
      Get.snackbar('Permasalahan kosong', 'Silakan isi permasalahan terlebih dahulu.');
      return;
    }

    final currentUser = user.value;
    if (currentUser == null) {
      Get.snackbar('Error', 'Data user tidak tersedia.');
      return;
    }

    try {
      isSending.value = true;

      await _supabase.from('bantuan').insert({
        'username': currentUser.username,
        'email': currentUser.email,
        'full_name': currentUser.fullName,
        'message': text,
      });

      Get.snackbar('Berhasil', 'Permasalahan berhasil dikirim.');
      messageController.clear();
    } catch (e) {
      Get.snackbar('Gagal', 'Terjadi kesalahan saat mengirim: $e');
    } finally {
      isSending.value = false;
    }
  }

  @override
  void onClose() {
    messageController.dispose();
    super.onClose();
  }
}

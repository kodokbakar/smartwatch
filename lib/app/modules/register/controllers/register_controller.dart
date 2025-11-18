import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../model/register_model.dart';

class RegisterController extends GetxController {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final isLoading = false.obs;
  final RegisterModel _model = RegisterModel();

  Future<void> register() async {
    final username = usernameController.text.trim();
    final password = passwordController.text;

    if (username.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Username dan password tidak boleh kosong');
      return;
    }

    isLoading.value = true;
    try {
      final exists = await _model.usernameExists(username);
      if (exists) {
        Get.snackbar('Error', 'Username sudah terdaftar');
      } else {
        await _model.insertUser(username, password);
        Get.snackbar('Berhasil', 'Registrasi berhasil');
        Get.back();
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal menyimpan data');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}

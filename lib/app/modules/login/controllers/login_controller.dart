import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/login_model.dart';

class LoginController extends GetxController {
  final LoginModel model = LoginModel(
    emailController: TextEditingController(),
    passwordController: TextEditingController(),
  );

  final isPasswordHidden = true.obs;
  final isLoading = false.obs;

  TextEditingController get emailController => model.emailController;
  TextEditingController get passwordController => model.passwordController;

  @override
  void onClose() {
    model.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void login() async {
    if (model.hasEmptyField) {
      Get.snackbar(
        'Error',
        'Please fill all fields',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
      return;
    }

    final supabase = Supabase.instance.client;
    final email = model.email;
    final password = model.password;

    isLoading.value = true;

    try {
      await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      isLoading.value = false;

      Get.offAllNamed('/home');

      Get.snackbar(
        'Sukses!',
        'Berhasil Login',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade400,
        colorText: Colors.white,
        duration: Duration(seconds: 3),
        margin: EdgeInsets.all(16),
        borderRadius: 12,
      );
    } on AuthException catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        e.message,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Something went wrong',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
    }
  }
}

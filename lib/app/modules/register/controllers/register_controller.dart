import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/register_model.dart';

class RegisterController extends GetxController {
  final RegisterModel model = RegisterModel(
    nameController: TextEditingController(),
    usernameController: TextEditingController(),
    emailController: TextEditingController(),
    passwordController: TextEditingController(),
    confirmPasswordController: TextEditingController(),
  );

  final isPasswordHidden = true.obs;
  final isConfirmPasswordHidden = true.obs;
  final isLoading = false.obs;

  TextEditingController get nameController => model.nameController;
  TextEditingController get usernameController => model.usernameController;
  TextEditingController get emailController => model.emailController;
  TextEditingController get passwordController => model.passwordController;
  TextEditingController get confirmPasswordController => model.confirmPasswordController;

  @override
  void onClose() {
    model.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }

  void register() async {
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

    if (model.password != model.confirmPassword) {
      Get.snackbar(
        'Error',
        'Passwords do not match',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
      return;
    }

    if (model.password.length < 6) {
      Get.snackbar(
        'Error',
        'Password must be at least 6 characters',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade400,
        colorText: Colors.white,
      );
      return;
    }

    final supabase = Supabase.instance.client;
    final fullName = model.fullName;
    final username = model.username;
    final email = model.email;
    final password = model.password;

    isLoading.value = true;

    try {
      final AuthResponse response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'username': username,
        },
      );

      final user = response.user;

      if (user == null) {
        isLoading.value = false;
        Get.snackbar(
          'Error',
          'Registration failed',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade400,
          colorText: Colors.white,
        );
        return;
      }

      await supabase.from('user').insert({
        'id': user.id,
        'email': email,
        'username': username,
        'full_name': fullName,
      });

      isLoading.value = false;

      Get.snackbar(
        'Success',
        'Registration successful!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade400,
        colorText: Colors.white,
      );

      Get.offNamed('/login');
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

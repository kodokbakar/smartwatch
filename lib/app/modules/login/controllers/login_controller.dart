import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/login_model.dart';

/// Abstraksi minimal agar login() mudah di-unit test.
///
/// Kenapa perlu?
/// - Production: tetap pakai Supabase + Get.snackbar + Get.offAllNamed.
/// - Test: bisa inject function palsu (mock/fake) tanpa inisialisasi Supabase.
typedef SignInFn = Future<void> Function({
required String email,
required String password,
});

typedef SnackbarFn = void Function({
required String title,
required String message,
required bool isError,
});

typedef NavigateFn = void Function();

class LoginController extends GetxController {
  LoginController({
    LoginModel? model,
    SignInFn? signIn,
    SnackbarFn? showSnackbar,
    NavigateFn? navigateToHome,
  })  : model = model ??
      LoginModel(
        emailController: TextEditingController(),
        passwordController: TextEditingController(),
      ),
        _signIn = signIn ?? _supabaseSignIn,
        _showSnackbar = showSnackbar ?? _getxSnackbar,
        _navigateToHome = navigateToHome ?? _defaultNavigateToHome;

  final LoginModel model;

  final SignInFn _signIn;
  final SnackbarFn _showSnackbar;
  final NavigateFn _navigateToHome;

  final isPasswordHidden = true.obs;
  final isLoading = false.obs;

  TextEditingController get emailController => model.emailController;
  TextEditingController get passwordController => model.passwordController;

  @override
  void onClose() {
    // Pastikan TextEditingController di-dispose untuk mencegah memory leak.
    model.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  /// Mengembalikan Future agar bisa di-await di unit test.
  /// Ini membuat test deterministik (tidak bergantung timing event loop).
  Future<void> login() async {
    // Validasi input: wajib isi semua field.
    if (model.hasEmptyField) {
      _showSnackbar(
        title: 'Error',
        message: 'Please fill all fields',
        isError: true,
      );
      return;
    }

    final email = model.email;
    final password = model.password;

    isLoading.value = true;

    try {
      // 1) Auth ke Supabase
      await _signIn(email: email, password: password);

      // 2) Navigasi setelah login sukses.
      // Urutan ini mengikuti perilaku awal: setelah login sukses, pindah layar.
      _navigateToHome();

      // 3) Snackbar sukses (UI feedback).
      _showSnackbar(
        title: 'Sukses!',
        message: 'Berhasil Login',
        isError: false,
      );
    } on AuthException catch (e) {
      // Error dari Supabase Auth (credential salah, email belum confirm, dsb.)
      _showSnackbar(
        title: 'Error',
        message: e.message,
        isError: true,
      );
    } catch (_) {
      // Error non-auth: network issue, parsing issue, atau dependency lain.
      _showSnackbar(
        title: 'Error',
        message: 'Something went wrong',
        isError: true,
      );
    } finally {
      // Pastikan loading selalu reset untuk menghindari tombol “macet”.
      isLoading.value = false;
    }
  }

  // ===== Default implementations (Production) =====

  static Future<void> _supabaseSignIn({
    required String email,
    required String password,
  }) async {
    final supabase = Supabase.instance.client;
    await supabase.auth.signInWithPassword(email: email, password: password);
  }

  static void _defaultNavigateToHome() {
    Get.offAllNamed('/home');
  }

  static void _getxSnackbar({
    required String title,
    required String message,
    required bool isError,
  }) {
    // Menjaga style snackbar agar sesuai implementasi awal.
    Get.snackbar(
      title,
      message,
      snackPosition: isError ? SnackPosition.BOTTOM : SnackPosition.TOP,
      backgroundColor:
      isError ? Colors.red.shade400 : Colors.green.shade400,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }
}

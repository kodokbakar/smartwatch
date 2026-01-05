import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/register_model.dart';

/// Abstraksi minimal untuk memudahkan unit test.
/// - Di production, default-nya tetap memanggil Supabase.
/// - Di test, kita bisa inject fungsi palsu/mocked tanpa perlu init Supabase.
typedef SignUpFn = Future<String?> Function({
required String email,
required String password,
required String fullName,
required String username,
});

typedef InsertUserFn = Future<void> Function({
required String userId,
required String email,
required String username,
required String fullName,
});

typedef SnackbarFn = void Function({
required String title,
required String message,
required bool isError,
});

typedef NavigateFn = void Function();

class RegisterController extends GetxController {
  RegisterController({
    RegisterModel? model,
    SignUpFn? signUp,
    InsertUserFn? insertUser,
    SnackbarFn? showSnackbar,
    NavigateFn? navigateToLogin,
  })  : model = model ??
      RegisterModel(
        nameController: TextEditingController(),
        usernameController: TextEditingController(),
        emailController: TextEditingController(),
        passwordController: TextEditingController(),
        confirmPasswordController: TextEditingController(),
      ),
        _signUp = signUp ?? _supabaseSignUp,
        _insertUser = insertUser ?? _supabaseInsertUser,
        _showSnackbar = showSnackbar ?? _getxSnackbar,
        _navigateToLogin = navigateToLogin ?? _defaultNavigateToLogin;

  final RegisterModel model;

  final SignUpFn _signUp;
  final InsertUserFn _insertUser;
  final SnackbarFn _showSnackbar;
  final NavigateFn _navigateToLogin;

  final isPasswordHidden = true.obs;
  final isConfirmPasswordHidden = true.obs;
  final isLoading = false.obs;

  TextEditingController get nameController => model.nameController;
  TextEditingController get usernameController => model.usernameController;
  TextEditingController get emailController => model.emailController;
  TextEditingController get passwordController => model.passwordController;
  TextEditingController get confirmPasswordController =>
      model.confirmPasswordController;

  @override
  void onClose() {
    // Pastikan semua controller form dibersihkan untuk menghindari memory leak.
    model.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordHidden.value = !isConfirmPasswordHidden.value;
  }

  /// Mengembalikan Future agar:
  /// 1) bisa di-await pada unit test
  /// 2) caller dapat menunggu proses selesai dengan deterministik
  Future<void> register() async {
    // Validasi input: field wajib diisi.
    if (model.hasEmptyField) {
      _showSnackbar(
        title: 'Error',
        message: 'Please fill all fields',
        isError: true,
      );
      return;
    }

    // Validasi input: password dan konfirmasi harus sama.
    if (model.password != model.confirmPassword) {
      _showSnackbar(
        title: 'Error',
        message: 'Passwords do not match',
        isError: true,
      );
      return;
    }

    // Validasi input: minimal panjang password.
    if (model.password.length < 6) {
      _showSnackbar(
        title: 'Error',
        message: 'Password must be at least 6 characters',
        isError: true,
      );
      return;
    }

    final fullName = model.fullName;
    final username = model.username;
    final email = model.email;
    final password = model.password;

    isLoading.value = true;

    try {
      // 1) Sign up ke Supabase Auth
      final userId = await _signUp(
        email: email,
        password: password,
        fullName: fullName,
        username: username,
      );

      // Defensive check: jika userId null, anggap signup gagal.
      if (userId == null) {
        _showSnackbar(
          title: 'Error',
          message: 'Registration failed',
          isError: true,
        );
        return;
      }

      // 2) Simpan profile/user data ke table aplikasi (public schema)
      await _insertUser(
        userId: userId,
        email: email,
        username: username,
        fullName: fullName,
      );

      _showSnackbar(
        title: 'Success',
        message: 'Registration successful!',
        isError: false,
      );

      // 3) Navigasi ke login
      _navigateToLogin();
    } on AuthException catch (e) {
      // Error dari Supabase Auth (mis. email sudah dipakai, rate limited, dsb.)
      _showSnackbar(
        title: 'Error',
        message: e.message,
        isError: true,
      );
    } catch (_) {
      // Error non-auth (network, parsing, insert table gagal, dsb.)
      _showSnackbar(
        title: 'Error',
        message: 'Something went wrong',
        isError: true,
      );
    } finally {
      // Pastikan loading selalu reset, bahkan bila terjadi error/return di tengah.
      isLoading.value = false;
    }
  }

  // ===== Default implementations (Production) =====

  static Future<String?> _supabaseSignUp({
    required String email,
    required String password,
    required String fullName,
    required String username,
  }) async {
    final supabase = Supabase.instance.client;

    final AuthResponse response = await supabase.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': fullName,
        'username': username,
      },
    );

    return response.user?.id;
  }

  static Future<void> _supabaseInsertUser({
    required String userId,
    required String email,
    required String username,
    required String fullName,
  }) async {
    final supabase = Supabase.instance.client;

    await supabase.from('user').insert({
      'id': userId,
      'email': email,
      'username': username,
      'full_name': fullName,
    });
  }

  static void _getxSnackbar({
    required String title,
    required String message,
    required bool isError,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor:
      isError ? Colors.red.shade400 : Colors.green.shade400,
      colorText: Colors.white,
    );
  }

  static void _defaultNavigateToLogin() {
    Get.offNamed('/login');
  }
}

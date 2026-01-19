import 'dart:async'; // untuk unawaited
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import '../models/register_model.dart';

/// Abstraksi minimal untuk memudahkan unit test (tetap bisa inject fungsi palsu).
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

/// Abstraksi GA4 supaya:
/// - production: pakai FirebaseAnalytics.instance
/// - unit test: bisa inject no-op/mock tanpa init Firebase
typedef AnalyticsLogEventFn = Future<void> Function({
  required String name,
  Map<String, Object?>? parameters,
});

typedef AnalyticsLogScreenViewFn = Future<void> Function({
  required String screenName,
});

typedef AnalyticsLogSignUpFn = Future<void> Function({
  required String signUpMethod,
});

typedef AnalyticsSetUserIdFn = Future<void> Function({
  required String? userId,
});

class RegisterController extends GetxController {
  RegisterController({
    RegisterModel? model,
    SignUpFn? signUp,
    InsertUserFn? insertUser,
    SnackbarFn? showSnackbar,
    NavigateFn? navigateToLogin,

    // Analytics injections (opsional)
    AnalyticsLogEventFn? analyticsLogEvent,
    AnalyticsLogScreenViewFn? analyticsLogScreenView,
    AnalyticsLogSignUpFn? analyticsLogSignUp,
    AnalyticsSetUserIdFn? analyticsSetUserId,
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
        _navigateToLogin = navigateToLogin ?? _defaultNavigateToLogin,
        _analyticsLogEvent = analyticsLogEvent ?? _firebaseLogEvent,
        _analyticsLogScreenView =
            analyticsLogScreenView ?? _firebaseLogScreenView,
        _analyticsLogSignUp = analyticsLogSignUp ?? _firebaseLogSignUp,
        _analyticsSetUserId = analyticsSetUserId ?? _firebaseSetUserId;

  final RegisterModel model;

  final SignUpFn _signUp;
  final InsertUserFn _insertUser;
  final SnackbarFn _showSnackbar;
  final NavigateFn _navigateToLogin;

  // GA4 handlers
  final AnalyticsLogEventFn _analyticsLogEvent;
  final AnalyticsLogScreenViewFn _analyticsLogScreenView;
  final AnalyticsLogSignUpFn _analyticsLogSignUp;
  final AnalyticsSetUserIdFn _analyticsSetUserId;

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
  void onInit() {
    super.onInit();

    // GA4: catat layar register sebagai screen_view.
    // Dipanggil non-blocking supaya tidak mengganggu init UI.
    unawaited(_analyticsLogScreenView(screenName: 'register'));
  }

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

  Future<void> register() async {
    // Validasi input: field wajib diisi.
    if (model.hasEmptyField) {
      await _analyticsLogEvent(
        name: 'sign_up_validation_failed',
        parameters: {'reason': 'empty_field'},
      );

      _showSnackbar(
        title: 'Error',
        message: 'Please fill all fields',
        isError: true,
      );
      return;
    }

    // Validasi input: password dan konfirmasi harus sama.
    if (model.password != model.confirmPassword) {
      await _analyticsLogEvent(
        name: 'sign_up_validation_failed',
        parameters: {'reason': 'password_mismatch'},
      );

      _showSnackbar(
        title: 'Error',
        message: 'Passwords do not match',
        isError: true,
      );
      return;
    }

    // Validasi input: minimal panjang password.
    if (model.password.length < 6) {
      await _analyticsLogEvent(
        name: 'sign_up_validation_failed',
        parameters: {'reason': 'password_too_short'},
      );

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

    // GA4: user menekan tombol register dan lolos validasi lokal.
    await _analyticsLogEvent(
      name: 'sign_up_attempt',
      parameters: {'method': 'email'},
    );

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
        await _analyticsLogEvent(
          name: 'sign_up_failed',
          parameters: {
            'method': 'email',
            'reason': 'null_user_id',
          },
        );

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

      // GA4 (recommended): catat sign up sukses.
      // FlutterFire menyediakan helper event "sign_up".
      await _analyticsLogSignUp(signUpMethod: 'email');

      // GA4: set user_id untuk mengikat event berikutnya.
      // Jangan pakai email/no HP (PII). UUID Supabase aman untuk ini.
      await _analyticsSetUserId(userId: userId);

      _showSnackbar(
        title: 'Success',
        message: 'Registration successful!',
        isError: false,
      );

      // 3) Navigasi ke login
      _navigateToLogin();
    } on AuthException catch (e) {
      await _analyticsLogEvent(
        name: 'sign_up_failed',
        parameters: {
          'method': 'email',
          'reason': _classifyAuthError(e.message),
        },
      );

      _showSnackbar(
        title: 'Error',
        message: e.message,
        isError: true,
      );
    } catch (_) {
      await _analyticsLogEvent(
        name: 'sign_up_failed',
        parameters: {
          'method': 'email',
          'reason': 'unknown_exception',
        },
      );

      _showSnackbar(
        title: 'Error',
        message: 'Something went wrong',
        isError: true,
      );
    } finally {
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
      backgroundColor: isError ? Colors.red.shade400 : Colors.green.shade400,
      colorText: Colors.white,
    );
  }

  static void _defaultNavigateToLogin() {
    Get.offNamed('/login');
  }

  // ===== GA4 default implementations (Production) =====
  // Referensi method yang tersedia: logSignUp, logScreenView, logEvent, setUserId. :contentReference[oaicite:5]{index=5}

  static Future<void> _firebaseLogEvent({
  required String name,
  Map<String, Object?>? parameters,
}) {
  // FirebaseAnalytics.logEvent umumnya menerima Map<String, Object> (tanpa null).
  // Jadi kita filter nilai null dan normalisasi tipe data parameter.
  Map<String, Object>? cleaned;

  if (parameters != null) {
    final tmp = <String, Object>{};

    for (final entry in parameters.entries) {
      final v = entry.value;
      if (v == null) continue;

      // GA4 parameter idealnya: String / int / double.
      if (v is String || v is int || v is double) {
        tmp[entry.key] = v;
      } else if (v is bool) {
        tmp[entry.key] = v ? 1 : 0; // normalisasi bool agar aman
      } else {
        tmp[entry.key] = v.toString(); // fallback aman
      }
    }

    cleaned = tmp.isEmpty ? null : tmp;
  }

  return FirebaseAnalytics.instance.logEvent(
    name: name,
    parameters: cleaned,
  );
}


  static Future<void> _firebaseLogScreenView({
    required String screenName,
  }) {
    return FirebaseAnalytics.instance.logScreenView(
      screenName: screenName,
    );
  }

  static Future<void> _firebaseLogSignUp({
    required String signUpMethod,
  }) {
    return FirebaseAnalytics.instance.logSignUp(
      signUpMethod: signUpMethod,
    );
  }

  static Future<void> _firebaseSetUserId({
    required String? userId,
  }) {
    return FirebaseAnalytics.instance.setUserId(id: userId);
  }

  // ===== Helper: kategorikan error tanpa mengirim message mentah ke GA4 =====
  static String _classifyAuthError(String message) {
    final m = message.toLowerCase();

    if (m.contains('already') && m.contains('email')) return 'email_already_used';
    if (m.contains('invalid') && m.contains('email')) return 'invalid_email';
    if (m.contains('password') && m.contains('weak')) return 'weak_password';
    if (m.contains('network') || m.contains('socket')) return 'network_error';

    return 'auth_error_other';
  }
}

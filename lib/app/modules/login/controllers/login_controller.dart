import 'dart:async'; // untuk unawaited
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import '../models/login_model.dart';

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

/// Abstraksi GA4 agar login() mudah di-test tanpa inisialisasi Firebase.
typedef AnalyticsLogEventFn = Future<void> Function({
  required String name,
  Map<String, Object?>? parameters,
});

typedef AnalyticsLogScreenViewFn = Future<void> Function({
  required String screenName,
});

typedef AnalyticsLogLoginFn = Future<void> Function({
  required String method,
});

typedef AnalyticsSetUserIdFn = Future<void> Function({
  required String? userId,
});

class LoginController extends GetxController {
  LoginController({
    LoginModel? model,
    SignInFn? signIn,
    SnackbarFn? showSnackbar,
    NavigateFn? navigateToHome,

    // Analytics injections (opsional)
    AnalyticsLogEventFn? analyticsLogEvent,
    AnalyticsLogScreenViewFn? analyticsLogScreenView,
    AnalyticsLogLoginFn? analyticsLogLogin,
    AnalyticsSetUserIdFn? analyticsSetUserId,
  })  : model = model ??
            LoginModel(
              emailController: TextEditingController(),
              passwordController: TextEditingController(),
            ),
        _signIn = signIn ?? _supabaseSignIn,
        _showSnackbar = showSnackbar ?? _getxSnackbar,
        _navigateToHome = navigateToHome ?? _defaultNavigateToHome,
        _analyticsLogEvent = analyticsLogEvent ?? _firebaseLogEvent,
        _analyticsLogScreenView =
            analyticsLogScreenView ?? _firebaseLogScreenView,
        _analyticsLogLogin = analyticsLogLogin ?? _firebaseLogLogin,
        _analyticsSetUserId = analyticsSetUserId ?? _firebaseSetUserId;

  final LoginModel model;

  final SignInFn _signIn;
  final SnackbarFn _showSnackbar;
  final NavigateFn _navigateToHome;

  // GA4 handlers
  final AnalyticsLogEventFn _analyticsLogEvent;
  final AnalyticsLogScreenViewFn _analyticsLogScreenView;
  final AnalyticsLogLoginFn _analyticsLogLogin;
  final AnalyticsSetUserIdFn _analyticsSetUserId;

  final isPasswordHidden = true.obs;
  final isLoading = false.obs;

  TextEditingController get emailController => model.emailController;
  TextEditingController get passwordController => model.passwordController;

  @override
  void onInit() {
    super.onInit();

    // GA4: catat layar login sebagai screen_view untuk analisis funnel.
    unawaited(_analyticsLogScreenView(screenName: 'login'));
  }

  @override
  void onClose() {
    model.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordHidden.value = !isPasswordHidden.value;
  }

  Future<void> login() async {
    // Validasi input: wajib isi semua field.
    if (model.hasEmptyField) {
      await _analyticsLogEvent(
        name: 'login_validation_failed',
        parameters: {'reason': 'empty_field'},
      );

      _showSnackbar(
        title: 'Error',
        message: 'Please fill all fields',
        isError: true,
      );
      return;
    }

    final email = model.email;
    final password = model.password;

    // GA4: user menekan tombol login (attempt).
    await _analyticsLogEvent(
      name: 'login_attempt',
      parameters: {'method': 'email'},
    );

    isLoading.value = true;

    try {
      // 1) Auth ke Supabase
      await _signIn(email: email, password: password);

      // 2) Set user_id di GA4 setelah login sukses.
      // Gunakan UUID Supabase, jangan pakai email/no HP.
      final userId = Supabase.instance.client.auth.currentUser?.id;
      await _analyticsSetUserId(userId: userId);

      // 3) GA4 (recommended): catat login sukses.
      await _analyticsLogLogin(method: 'email');

      // 4) Navigasi setelah login sukses.
      _navigateToHome();

      // 5) Snackbar sukses.
      _showSnackbar(
        title: 'Sukses!',
        message: 'Berhasil Login',
        isError: false,
      );
    } on AuthException catch (e) {
      // GA4: login gagal karena auth error (credential salah, dsb).
      await _analyticsLogEvent(
        name: 'login_failed',
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
      // GA4: login gagal karena error lain (network, parsing, dll).
      await _analyticsLogEvent(
        name: 'login_failed',
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
    Get.snackbar(
      title,
      message,
      snackPosition: isError ? SnackPosition.BOTTOM : SnackPosition.TOP,
      backgroundColor: isError ? Colors.red.shade400 : Colors.green.shade400,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
    );
  }

  // ===== GA4 default implementations (Production) =====

  static Future<void> _firebaseLogEvent({
    required String name,
    Map<String, Object?>? parameters,
  }) {
    // FirebaseAnalytics.logEvent butuh Map<String, Object> tanpa nilai null.
    Map<String, Object>? cleaned;

    if (parameters != null) {
      final tmp = <String, Object>{};
      for (final entry in parameters.entries) {
        final v = entry.value;
        if (v == null) continue;

        // Parameter GA4 aman: String/int/double.
        if (v is String || v is int || v is double) {
          tmp[entry.key] = v;
        } else if (v is bool) {
          tmp[entry.key] = v ? 1 : 0;
        } else {
          tmp[entry.key] = v.toString();
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

  static Future<void> _firebaseLogLogin({
    required String method,
  }) {
    // Recommended event GA4: "login"
    return FirebaseAnalytics.instance.logLogin(loginMethod: method);
  }

  static Future<void> _firebaseSetUserId({
    required String? userId,
  }) {
    return FirebaseAnalytics.instance.setUserId(id: userId);
  }

  // Kategorikan error agar yang terkirim ke GA4 tidak berupa pesan mentah.
  static String _classifyAuthError(String message) {
    final m = message.toLowerCase();

    if (m.contains('invalid') && (m.contains('login') || m.contains('credentials'))) {
      return 'invalid_credentials';
    }
    if (m.contains('email') && m.contains('confirm')) return 'email_not_confirmed';
    if (m.contains('rate') && m.contains('limit')) return 'rate_limited';
    if (m.contains('network') || m.contains('socket')) return 'network_error';

    return 'auth_error_other';
  }
}

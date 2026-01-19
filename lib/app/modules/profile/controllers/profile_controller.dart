import 'dart:async'; // untuk unawaited
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import '../../../data/models/user_model.dart';
import '../../../data/picture/minidenticon_generator.dart';

/// Abstraksi GA4 agar mudah di-unit test (bisa inject no-op/mock).
typedef AnalyticsLogEventFn = Future<void> Function({
  required String name,
  Map<String, Object?>? parameters,
});

typedef AnalyticsLogScreenViewFn = Future<void> Function({
  required String screenName,
});

typedef AnalyticsSetUserIdFn = Future<void> Function({
  required String? userId,
});

class ProfileController extends GetxController {
  ProfileController({
    SupabaseClient? supabase,
    AnalyticsLogEventFn? analyticsLogEvent,
    AnalyticsLogScreenViewFn? analyticsLogScreenView,
    AnalyticsSetUserIdFn? analyticsSetUserId,
  })  : _supabase = supabase ?? Supabase.instance.client,
        _analyticsLogEvent = analyticsLogEvent ?? _firebaseLogEvent,
        _analyticsLogScreenView =
            analyticsLogScreenView ?? _firebaseLogScreenView,
        _analyticsSetUserId = analyticsSetUserId ?? _firebaseSetUserId;

  final SupabaseClient _supabase;

  // GA4 handlers
  final AnalyticsLogEventFn _analyticsLogEvent;
  final AnalyticsLogScreenViewFn _analyticsLogScreenView;
  final AnalyticsSetUserIdFn _analyticsSetUserId;

  final user = Rxn<AppUser>();
  final isLoading = false.obs;
  final errorMessage = RxnString();

  /// SVG avatar hasil generate dari username.
  /// View tidak perlu tahu cara membuatnya, cukup render string ini.
  final avatarSvg = ''.obs;

  @override
  void onInit() {
    super.onInit();

    // GA4: catat halaman profile dibuka.
    unawaited(_analyticsLogScreenView(screenName: 'profile'));
    unawaited(_analyticsLogEvent(name: 'profile_open'));

    fetchProfile();
  }

  Future<void> fetchProfile() async {
    isLoading.value = true;
    errorMessage.value = null;

    // GA4: mulai proses fetch profile (berguna untuk analisis latency/failure rate).
    unawaited(_analyticsLogEvent(
      name: 'profile_fetch_start',
      parameters: {'source': 'supabase'},
    ));

    try {
      final authUser = _supabase.auth.currentUser;

      if (authUser == null) {
        errorMessage.value = 'User not logged in';
        user.value = null;
        avatarSvg.value = '';

        // GA4: gagal karena user belum login.
        unawaited(_analyticsLogEvent(
          name: 'profile_fetch_failed',
          parameters: {'reason': 'not_logged_in'},
        ));
        return;
      }

      final data = await _supabase
          .from('user') // table: public.user
          .select()
          .eq('id', authUser.id)
          .maybeSingle();

      if (data == null) {
        errorMessage.value = 'Profile data not found';
        user.value = null;
        avatarSvg.value = '';

        // GA4: gagal karena row profile tidak ditemukan.
        unawaited(_analyticsLogEvent(
          name: 'profile_fetch_failed',
          parameters: {'reason': 'not_found'},
        ));
      } else {
        final appUser = AppUser.fromJson(data);
        user.value = appUser;

        // Seed utama: username. Fallback: email agar tetap stabil.
        final seed = (appUser.username).trim().isNotEmpty
            ? appUser.username
            : (appUser.email ?? 'user');

        avatarSvg.value = MinidenticonGenerator.svg(seed);

        // GA4: sukses load profile.
        // Hindari kirim data sensitif (email/username mentah). Cukup boolean/flag.
        unawaited(_analyticsLogEvent(
          name: 'profile_fetch_success',
          parameters: {
            'has_username': (appUser.username).trim().isNotEmpty ? 1 : 0,
          },
        ));
      }
    } catch (e) {
      errorMessage.value = 'Failed to load profile: $e';

      // GA4: error tak terduga saat fetch.
      unawaited(_analyticsLogEvent(
        name: 'profile_fetch_failed',
        parameters: {'reason': 'exception'},
      ));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    // GA4: user mencoba logout.
    unawaited(_analyticsLogEvent(name: 'logout_attempt'));

    try {
      await _supabase.auth.signOut();

      // Reset state lokal agar UI tidak “nyangkut” user lama.
      user.value = null;
      avatarSvg.value = '';

      // GA4: bersihkan user_id agar event setelah logout tidak terikat user sebelumnya.
      await _analyticsSetUserId(userId: null);

      // GA4: logout sukses.
      unawaited(_analyticsLogEvent(name: 'logout_success'));

      Get.toNamed('/login');
    } catch (e) {
      // GA4: logout gagal.
      unawaited(_analyticsLogEvent(
        name: 'logout_failed',
        parameters: {'reason': 'exception'},
      ));

      Get.snackbar('Logout Failed', e.toString());
    }
  }

  void goToProfileDetail() {
    // GA4: user membuka halaman detail profile.
    unawaited(_analyticsLogEvent(name: 'profile_detail_open'));
    Get.toNamed('/profile-detail');
  }

  void goToHelp() {
    // GA4: user membuka halaman bantuan.
    unawaited(_analyticsLogEvent(name: 'help_open'));
    Get.toNamed('/helper');
  }

  void goToAboutApp() {
    // GA4: user membuka dialog about.
    unawaited(_analyticsLogEvent(name: 'about_app_open'));

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: SizedBox(
          width: Get.width * 0.85,
          height: 260,
          child: Stack(
            children: [
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

  static Future<void> _firebaseSetUserId({
    required String? userId,
  }) {
    return FirebaseAnalytics.instance.setUserId(id: userId);
  }
}

import 'package:get/get.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class SplashscreenController extends GetxController {
  // GA4 instance
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  @override
  void onInit() {
    super.onInit();

    // GA4: catat splash screen dibuka
    _analytics.logScreenView(screenName: 'splash');
    _analytics.logEvent(name: 'splash_open');
  }

  void goToNextPage() {
    // GA4: catat aksi navigasi dari splash ke halaman berikutnya
    _analytics.logEvent(
      name: 'splash_navigate_next',
      parameters: {'to': 'welcome'},
    );

    // Navigasi ke halaman berikutnya setelah splash screen
    Get.offNamed('/welcome');
  }
}

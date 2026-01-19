import 'package:get/get.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

class WelcomeController extends GetxController {
  // GA4 instance
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  @override
  void onInit() {
    super.onInit();

    // GA4: catat welcome screen dibuka
    _analytics.logScreenView(screenName: 'welcome');
    _analytics.logEvent(name: 'welcome_open');
  }

  void goToLogin() {
    // GA4: user memilih masuk ke halaman login
    _analytics.logEvent(name: 'welcome_go_to_login');

    // Navigate to login page
    Get.toNamed('/login');
  }

  void goToRegister() {
    // GA4: user memilih masuk ke halaman register
    _analytics.logEvent(name: 'welcome_go_to_register');

    // Navigate to register page
    Get.toNamed('/register');
  }
}

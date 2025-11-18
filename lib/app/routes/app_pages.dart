import 'package:get/get.dart';

import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';

// Dummy modules (tambahkan sesuai kebutuhan)
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/profile/bindings/profile_binding.dart';
import '../modules/profile/views/profile_view.dart';
import '../modules/settings/bindings/settings_binding.dart';
import '../modules/settings/views/settings_view.dart';
import '../modules/detail/bindings/detail_binding.dart';
import '../modules/detail/views/detail_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  // Command: halaman yang pertama dibuka
  static const INITIAL = Routes.HOME;

  static final routes = [
    // ==========================
    // HOME PAGE
    // ==========================
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),

    // ==========================
    // LOGIN PAGE — dummy
    // ==========================
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),

    // ==========================
    // PROFILE PAGE — dummy
    // ==========================
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),

    // ==========================
    // SETTINGS PAGE — dummy
    // ==========================
    GetPage(
      name: _Paths.SETTINGS,
      page: () => const SettingsView(),
      binding: SettingsBinding(),
    ),

    // ==========================
    // DETAIL PAGE — dummy param (:id)
    // ==========================
    GetPage(
      name: _Paths.DETAIL,
      page: () => const DetailView(),
      binding: DetailBinding(),
    ),
  ];
}

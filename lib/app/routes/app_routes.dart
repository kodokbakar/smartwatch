part of 'app_pages.dart';
// DO NOT EDIT. This is code generated via package:get_cli/get_cli.dart

abstract class Routes {
  Routes._();

  // Halaman utama
  static const HOME = _Paths.HOME;

  // Dummy tambahan
  static const LOGIN = _Paths.LOGIN;           // Route ke halaman login
  static const PROFILE = _Paths.PROFILE;       // Route ke halaman profil
  static const SETTINGS = _Paths.SETTINGS;     // Route ke halaman pengaturan
  static const DETAIL = _Paths.DETAIL;         // Route ke halaman detail item
  static const DASHBOARD = _Paths.DASHBOARD;   // Route ke dashboard
}

abstract class _Paths {
  _Paths._();

  // Path asli
  static const HOME = '/home';

  // Dummy tambahan
  static const LOGIN = '/login';               // Path login
  static const PROFILE = '/profile';           // Path profil user
  static const SETTINGS = '/settings';         // Path pengaturan aplikasi
  static const DETAIL = '/detail/:id';         // Path detail dengan parameter
  static const DASHBOARD = '/dashboard';       // Path dashboard utama
}

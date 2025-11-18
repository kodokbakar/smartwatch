part of 'app_pages.dart';

abstract class Routes {
  Routes._();
  static const HOME = _Paths.HOME;
  static const SPLASHSCREEN = _Paths.SPLASHSCREEN;
  static const WELCOME = _Paths.WELCOME;
  static const REGISTER = _Paths.REGISTER;
}

abstract class _Paths {
  _Paths._();
  static const HOME = '/home';
  static const SPLASHSCREEN = '/splashscreen';
  static const WELCOME = '/welcome';
  static const REGISTER = '/register';
}

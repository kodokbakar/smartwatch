import 'package:get/get.dart';

class WelcomeController extends GetxController {
  //TODO: Implement WelcomeController

  void goToLogin() {
    // Navigate to login page
    Get.toNamed('/login');
  }

  void goToRegister() {
    // Navigate to register page
    Get.toNamed('/register');
  }
}

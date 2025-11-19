import 'package:get/get.dart';

class SplashscreenController extends GetxController {
  //TODO: Implement SplashscreenController

  void goToNextPage() {
    // Logic to navigate to the next page after splash screen
    Get.offNamed('/welcome');
  }
}

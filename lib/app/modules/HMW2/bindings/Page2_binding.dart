import 'package:get/get.dart';
import '../controllers/Page2_controller.dart';

class Page2Binding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<Page2Controller>(
          () => Page2Controller(),
    );
  }
}
import 'package:get/get.dart';
import '../controllers/public_complaint_controller.dart';

class PublicComplaintBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PublicComplaintController>(() => PublicComplaintController());
  }
}

import 'package:get/get.dart';
import '../controllers/distribution_activities_controller.dart';

class DistributionActivitiesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DistributionActivitiesController>(
      () => DistributionActivitiesController(),
    );
  }
}

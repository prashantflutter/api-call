import 'package:get/get.dart';

import '../controllers/work_availability_controller.dart';

class WorkAvailabilityBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(WorkAvailabilityController());
  }
}

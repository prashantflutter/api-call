import 'package:get/get.dart';

import '../controllers/work_schedule_controller.dart';

class WorkScheduleBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(WorkScheduleController());
  }
}

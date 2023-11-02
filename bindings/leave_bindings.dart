import 'package:get/get.dart';

import '../controllers/leave_controller.dart';

class LeaveBindings extends Bindings{
  @override
  void dependencies() {
    Get.put(LeaveController());
  }

}
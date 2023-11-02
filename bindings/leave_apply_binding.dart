import 'package:get/get.dart';

import '../controllers/leave_apply_controller.dart';

class LeaveApplyBindings extends Bindings{

  @override
  void dependencies() {
    Get.put(LeaveApplyController());
  }

}
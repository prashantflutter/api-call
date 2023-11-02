import 'package:get/get.dart';

import '../controllers/attendance_controller.dart';

class AttendanceBindings extends Bindings{
  @override
  void dependencies() {
    Get.put(AttendanceController(),);
  }

}
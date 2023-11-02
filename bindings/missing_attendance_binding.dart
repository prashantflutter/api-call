import 'package:get/get.dart';

import '../controllers/missing_attendance_controller.dart';

class MissingAttendanceBindings extends Bindings{
  @override
  void dependencies() {
    Get.put(MissingAttendanceController());
  }

}
import 'package:ehubt_finanace_expence/services/auth_api.dart';
import 'package:get/get.dart';

import '../controllers/employee_main_controller.dart';
import '../controllers/employee_video_controller.dart';


class VideoPlayerBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(EmployeeVideoController());
  }
}
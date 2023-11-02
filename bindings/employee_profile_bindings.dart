import 'package:get/get.dart';

import '../controllers/employee_profile_controller.dart';

class EmployeeProfileBindings extends Bindings{
  @override
  void dependencies() {
    Get.put(EmployeeProfileController());
  }

}
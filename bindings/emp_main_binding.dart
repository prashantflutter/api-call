import 'package:get/get.dart';

import '../controllers/employee_main_controller.dart';

class EmployeeMainBindings extends Bindings{
  @override
  void dependencies() {
    Get.put(EmployeeMainController());
  }
}
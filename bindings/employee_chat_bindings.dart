import 'package:get/get.dart';

import '../controllers/employee_chat_controller.dart';

class EmployeeChatBindings extends Bindings{
  @override
  void dependencies() {
   Get.put(EmployeeChatController());
  }

}
import 'package:ehubt_finanace_expence/logic/controllers/admin_main_controller.dart';
import 'package:get/get.dart';

class AdminMainBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(AdminMainController());
  }
}

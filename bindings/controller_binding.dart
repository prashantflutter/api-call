import 'package:ehubt_finanace_expence/logic/controllers/connection_manager_controller.dart';
import 'package:get/get.dart';

class ControllerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ConnectionManagerController>(() => ConnectionManagerController());
  }
}

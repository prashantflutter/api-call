import 'package:get/get.dart';

import '../controllers/request_shift_swap_controller.dart';

class RequestShiftSwapBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(RequestShiftSwapController());
  }
}

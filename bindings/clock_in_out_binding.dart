import 'package:get/get.dart';

import '../controllers/clock_in_out_controller.dart';

class ClockInOutBindings extends Bindings{
  @override
  void dependencies() {
    Get.put(ClockInOutController());
  }

}
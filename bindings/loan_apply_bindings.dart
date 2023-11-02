import 'package:get/get.dart';

import '../controllers/loan_apply_controller.dart';

class LoanApplyBindings extends Bindings{
  @override
  void dependencies() {
    Get.put(LoanApplyController());
  }

}
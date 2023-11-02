import 'package:get/get.dart';

import '../controllers/loan_type_controller.dart';

class LoanTypeBindings extends Bindings{
  @override
  void dependencies() {
    Get.put(LoanTypeController());
  }

}
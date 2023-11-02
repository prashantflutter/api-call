import 'package:get/get.dart';

import '../controllers/loan_detail_controller.dart';

class LoanDetailBindings extends Bindings{
  @override
  void dependencies() {
    Get.put(LoanDetailController());
  }

}
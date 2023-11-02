import 'package:get/get.dart';

import '../controllers/loan_controller.dart';

class LoanBindings extends Bindings{
  @override
  void dependencies() {
   Get.put(LoanController());
  }

}
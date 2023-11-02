import 'package:get/get.dart';

import '../controllers/salary_statement_controller.dart';

class SalaryStatementBindings extends Bindings{
  @override
  void dependencies() {
      Get.put(SalaryStatementController());
  }

}
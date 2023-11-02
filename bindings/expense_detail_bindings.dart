import 'package:get/get.dart';

import '../controllers/expense_controller.dart';
import '../controllers/expense_detail_controller.dart';

class ExpenseDetailBinding extends Bindings{
  @override
  void dependencies() {
    Get.put(ExpenseDetailController());
  }

}
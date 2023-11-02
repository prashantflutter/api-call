import 'package:get/get.dart';


import '../controllers/finance_main_controller.dart';

class FinanceMainBinding extends Bindings{
  @override
  void dependencies() {
    Get.put(FinanceMainController());

  }

}
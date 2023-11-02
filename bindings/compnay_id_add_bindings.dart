import 'package:ehubt_finanace_expence/logic/controllers/company_id_add_controller.dart';
import 'package:get/get.dart';

class CompanyIdAddBindings extends Bindings{
  @override
  void dependencies() {
   Get.put(CompanyIdAddController());
  }

}
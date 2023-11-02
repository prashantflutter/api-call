import 'package:get/get.dart';

import '../controllers/company_policy_controller.dart';

class CompanyPolicyBindings extends Bindings{
  @override
  void dependencies() {
    Get.put(CompanyPolicyController());
  }

}
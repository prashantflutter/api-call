import 'package:get/get.dart';

import '../controllers/employee_chat_controller.dart';
import '../controllers/privay_policiy_controller.dart';

class PrivacyPolicyBindings extends Bindings{
  @override
  void dependencies() {
   Get.put(PrivacyPolicyController());
  }

}
import 'package:get/get.dart';

import '../controllers/terms_and_condtion_controller.dart';

class TermsConditionBindings extends Bindings{
  @override
  void dependencies() {
    Get.put(TermsConditionController());
  }

}
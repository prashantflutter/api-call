import 'package:get/get.dart';

import '../controllers/address_controller.dart';

class AddressBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(AddressController());
  }
}

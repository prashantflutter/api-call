import 'package:get/get.dart';

import '../controllers/e_rotas_controller.dart';

class RotasBindings extends Bindings{
  @override
  void dependencies() {
    Get.put(RotasController());
  }

}
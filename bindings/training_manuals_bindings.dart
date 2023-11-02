import 'package:get/get.dart';

import '../controllers/training_manuals_controller.dart';

class TrainingManualsBindings extends Bindings{
  @override
  void dependencies() {
    Get.put(TrainingManualsController());
  }

}
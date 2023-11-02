import 'package:get/get.dart';

import '../controllers/training_controller.dart';

class TrainingBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(TrainingController());
  }
}

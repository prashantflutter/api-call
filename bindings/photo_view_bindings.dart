import 'package:get/get.dart';

import '../controllers/photo_view_zoom_controller.dart';

class PhotoViewBindings extends Bindings{
  @override
  void dependencies() {
    Get.put(PhotoViewZoomController());
  }

}
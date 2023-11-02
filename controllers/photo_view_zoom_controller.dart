import 'package:get/get.dart';

class PhotoViewZoomController extends GetxController {
  var photoUrl = '';
  @override
  void onReady() {
    photoUrl = Get.arguments[0];
    print("URL : $photoUrl");

    update();
    super.onReady();
  }
}

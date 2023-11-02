import 'package:get/get.dart';


import '../controllers/video_player_controllers.dart';

class VideoPlayerBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(VideoController());
  }
}

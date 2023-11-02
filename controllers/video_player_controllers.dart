import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../routes/routes.dart';
import '../../screens/on_boarding_screen/components/data/static_data.dart';
import '../../utils/constant/app_string.dart';
import '../../utils/sharPreferenceUtils.dart';

class VideoController extends GetxController {
  // late VideoPlayerController controller;
  bool initialized = false;
    int currentIndex = 0;
  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    // controller = VideoPlayerController.network(sliderList[currentIndex]['video_url'].toString())
    //   ..initialize().then((_) {
    //     controller.setLooping(true);
    //     initialized = true;
    //     update();
    //   });
  }

  void changePageIndex(index){
    // controller.dispose();
    currentIndex = index;
    // controller = VideoPlayerController.network(sliderList[index]['video_url'].toString())
    //   ..initialize().then((_) {
    //     controller.setLooping(true);
    //     initialized = true;
    //     update();
    //   });

    update();
  }

  void videoDispose(){
    // controller.dispose();
    update();
  }

  void gotoNextScreen(){
    SharedPrefs.instance.setBool(checkIntroScree, true);
    Get.offNamed(Routes.selectLoginTypeScreen);
  }

}

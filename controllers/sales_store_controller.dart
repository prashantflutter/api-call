import 'package:get/get.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../utils/sharPreferenceUtils.dart';

class SalesStoreController extends GetxController {
  bool loading = false;
  var sharePref = SharedPrefs.instance;

  @override
  void onInit() {
    super.onInit();
  }

  void startLoading() {
    loading = true;
    update();
  }


  void stopLoading() {
    loading = false;
    update();
  }
}

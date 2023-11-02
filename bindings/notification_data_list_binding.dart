import 'package:get/get.dart';

import '../controllers/notification_data_list_controller.dart';
import '../controllers/profile_controller.dart';

class NotificationDataListBinding extends Bindings{
  @override
  void dependencies() {
    Get.put(Get.put(NotificationDataListController()));
  }

}
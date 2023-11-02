import 'package:get/get.dart';

class TrainingController extends GetxController{
  late List courseList;
  @override
  void onInit() {

    super.onInit();
    courseList = ['Courses','Training Manuals','Training Manuals','Company Policy'];
    update();
  }
}
import 'dart:convert';

import 'package:get/get.dart';


import '../../employee_screen/model/training/announcement_model.dart';
import '../../employee_screen/screens/employee_main_screen/employee_training/employee_training_screen.dart';
import '../../services/attendance_services.dart';
import '../../services/employee_training.dart';
import '../../utils/constant/app_string.dart';
import '../../utils/sharPreferenceUtils.dart';

class AnnouncementsController extends GetxController {

  var sharePref = SharedPrefs.instance;
  bool loading = false;
  List<AnnouncementData> announcementData = [];


  @override
  void onInit() {
    super.onInit();
    getAnnouncementsList();
  }

  void startLoading() {
    loading = true;
    update();
  }

  void stopLoading() {
    loading = false;
    update();
  }


  getAnnouncementsList()async{
    startLoading();
    try{
      var response = await EmployeeTrainingServices.get_List_of_Announcements(authToken: sharePref.getString(authToken) ?? '',
          user_id: sharePref.getString(userId) ?? '');
      print("Response AnnouncementsList Report : ${response.toString()}");
      AnnouncementModel announcementModel = AnnouncementModel.fromJson(jsonDecode(response.data));

      if(response.statusCode == 200){
        if(announcementModel.success == true){
          stopLoading();
          announcementData.clear();
          announcementData.addAll((announcementModel.data)!.map((e) => AnnouncementData.fromJson(e.toJson())).toList());

          update();

          print("Connect to Server Successful...");
        }else{
          stopLoading();
          print("Something went to wrong ?");
        }
      }else{
        stopLoading();
        print("Something went to wrong ???");
      }
    }catch(e){
      stopLoading();
      print("error : $e");
    }
  }

}
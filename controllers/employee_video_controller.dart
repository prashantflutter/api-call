
import 'dart:convert';



import 'package:get/get.dart';


import '../../components/get_snackbar.dart';
import '../../employee_screen/model/employee_video_player/employee_video_play_model.dart';


import '../../services/auth_api.dart';


class EmployeeVideoController extends GetxController {

  bool loading = false;
  List<Detail> thubNailList = [];

  @override
  void onInit() {
    super.onInit();
    getEmployeeVideoPlay();

  }

  void startLoading() {
    loading = true;
    update();
  }

  void stopLoading() {
    loading = false;
    update();
  }



  getEmployeeVideoPlay() async {
    startLoading();
    try {
      var response = await AuthApi.employeeVideoPlay();
      VideoPlayerModel videoPlayerModel = VideoPlayerModel.fromJson(
        json.decode(response.data),
      );



      if (response.statusCode == 200) {
        print("Response : $response");

        if (videoPlayerModel.success == true) {
          stopLoading();
          thubNailList.addAll((videoPlayerModel?.data)!.map((x) => Detail.fromJson(x.toJson())).toList());
          update();
        } else {
          stopLoading();
          GetSnackbar(supTitle: videoPlayerModel.message.toString(), title: "Error");
        }
      } else {
        stopLoading();
        GetSnackbar(supTitle: videoPlayerModel.message.toString(), title: "Error");
      }
    } catch (e) {
      print("Error : ${e.toString()}");
      stopLoading();
      GetSnackbar(supTitle: '', title: "Oops! Something went wrong.");
    }
  }
}

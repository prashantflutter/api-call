import 'dart:convert';

import 'package:get/get.dart';

import '../../components/get_snackbar.dart';
import '../../employee_screen/model/employee_profile/employee_profile.dart';
import '../../services/auth_api.dart';
import '../../utils/constant/app_string.dart';
import '../../utils/sharPreferenceUtils.dart';

class EmployeeProfileController extends GetxController {
  var sharePref = SharedPrefs.instance;
  bool loading = false;

  @override
  void onInit() {
    getProfile();
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

  getProfile() async {
    startLoading();
    try {
      var response = await AuthApi.employeeProfile(authToken: sharePref.getString(authToken) ?? '', userId: sharePref.getString(userId) ?? '');
      EmployeeProfile employeeProfile = EmployeeProfile.fromJson(json.decode(response.data));

      print("Response Employee Profile => : $response");

      if (response.statusCode == 200) {
        stopLoading();

        if (employeeProfile.success == true) {


          sharePref.setString(userName, '${employeeProfile.data!.firstName} ${employeeProfile.data!.lastName}');
          sharePref.setString(profilePicture, '${employeeProfile.data!.userImage}');
          sharePref.setString('designation', '${employeeProfile.data!.designationName}');
          sharePref.setString('EmployeeChatUrl', '${employeeProfile.data!.chatUrl}');

          update();
        }
      } else {
        stopLoading();
        GetSnackbar(supTitle: employeeProfile.message.toString(), title: "Error");
      }
    } catch (e) {
      stopLoading();
      GetSnackbar(supTitle: '', title: "Oops! Something went wrong.");
    }
  }
}

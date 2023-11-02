import 'dart:convert';

import 'package:get/get.dart';

import '../../components/get_snackbar.dart';
import '../../model/company_verify.dart';
import '../../routes/routes.dart';
import '../../services/auth_api.dart';
import '../../utils/sharPreferenceUtils.dart';

class CompanyIdAddController extends GetxController{
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

  Future<void> companyVerify({required String companyKey}) async {
    startLoading();
    try {
      var response  = await AuthApi.companyVerify(companyKey: companyKey);
      CompanyVerify companyVerify = CompanyVerify.fromJson(json.decode(response.data));

      print("Response : $response");
      if (response.statusCode == 200) {
        stopLoading();
        if(companyVerify.success == true){
          sharePref.setString('companyKey', '${companyVerify.data!}');
          Get.offNamed(Routes.loginScreen);
        }
      }else{
        stopLoading();
        GetSnackbar(supTitle: companyVerify.message.toString(), title: "Error");
      }
    } catch (e) {
      stopLoading();
      GetSnackbar(supTitle: '', title: "Oops! Something went wrong.");
    }
  }


}


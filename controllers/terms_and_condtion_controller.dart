import 'dart:convert';

import 'package:ehubt_finanace_expence/services/auth_api.dart';
import 'package:get/get.dart';

import '../../components/get_snackbar.dart';
import '../../model/terms_condtion_model.dart';

class TermsConditionController extends GetxController{
  bool loading = false;
  var termsConditionData = '';
  @override
  void onReady() {
    getTermsCondition();
    super.onReady();
  }

  void startLoading() {
    loading = true;
    update();
  }

  void stopLoading() {
    loading = false;
    update();
  }

  getTermsCondition() async {
    startLoading();
    try {
      var response = await AuthApi.termsCondition();
      TermsConditionModel termsConditionModel = TermsConditionModel.fromJson(json.decode(response.data));

      print("Response Terms & Condition => : $response");

      if (response.statusCode == 200) {
        if (termsConditionModel.success == true) {
          termsConditionData = termsConditionModel.data != null ? termsConditionModel.data! : '';
          update();
          stopLoading();
        } else {
          stopLoading();
          GetSnackbar(
              supTitle: termsConditionModel.message.toString(), title: "Error");
        }
      } else {
        stopLoading();
        GetSnackbar(
            supTitle: termsConditionModel.message.toString(), title: "Error");
      }
    } catch (e) {
      print("Error : ${e.toString()}");
      stopLoading();
      GetSnackbar(supTitle: '', title: "Oops! Something went wrong.");
    }
  }
}
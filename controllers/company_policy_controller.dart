import 'dart:convert';

import 'package:ehubt_finanace_expence/employee_screen/model/training/company_policy_model.dart';
import 'package:get/get.dart';

import '../../components/get_snackbar.dart';
import '../../services/employee_training.dart';

class CompanyPolicyController extends GetxController {
  bool loading = false;
  var companyPolicyUrl;

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    getCompanyPolicy();
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

  getCompanyPolicy() async {
    startLoading();
    try {
      var response = await EmployeeTrainingServices.companyPolicy();
      CompanyPolicyModel companyPolicyModel = CompanyPolicyModel.fromJson(json.decode(response.data));

      print("Response Employee Profile => : $response");

      if (response.statusCode == 200) {
        stopLoading();

        if (companyPolicyModel.success == true) {
          companyPolicyUrl = companyPolicyModel.data;
          update();
        }
      } else {
        stopLoading();
        GetSnackbar(supTitle: companyPolicyModel.message.toString(), title: "Error");
      }
    } catch (e) {
      stopLoading();
      GetSnackbar(supTitle: '', title: "Oops! Something went wrong.");
    }
  }
}

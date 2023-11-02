import 'dart:convert';

import 'package:get/get.dart';

import '../../components/get_snackbar.dart';
import '../../employee_screen/model/loan/loan_type.dart';
import '../../services/loan_services.dart';
import '../../utils/constant/app_string.dart';
import '../../utils/sharPreferenceUtils.dart';

class LoanTypeController extends GetxController{
  var sharePref = SharedPrefs.instance;
  bool loading = false;
  List<LoanTypeData> loanTypeList = [];
  @override
  void onInit() {
    getLoanType();
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

  getLoanType() async {
    startLoading();
    try {
      var response = await LoanApi.getLoanType(authToken: sharePref.getString(authToken) ?? '', userId: sharePref.getString(userId) ?? '');
      LoanType loanType = LoanType.fromJson(json.decode(response.data));

      print("Response LoanType => : $response");

      if (response.statusCode == 200) {
        if (loanType.success == true) {
          loanTypeList.clear();
          loanTypeList.addAll((loanType?.data)!.map((x) => LoanTypeData.fromJson(x.toJson())).toList());
          update();
          stopLoading();
        } else {
          stopLoading();
          GetSnackbar(supTitle: loanType.message.toString(), title: "Error");
        }
      } else {
        stopLoading();
        GetSnackbar(supTitle: loanType.message.toString(), title: "Error");
      }
    } catch (e) {
      print("Error : ${e.toString()}");
      stopLoading();
      GetSnackbar(supTitle: '', title: "Oops! Something went wrong.");
    }
  }
}
import 'dart:convert';

import 'package:get/get.dart';


import '../../components/get_snackbar.dart';
import '../../employee_screen/model/loan/loan_detail.dart';

import '../../services/loan_services.dart';
import '../../utils/constant/app_string.dart';
import '../../utils/sharPreferenceUtils.dart';

class LoanController extends GetxController {
  var sharePref = SharedPrefs.instance;
  bool loading = false;
  List<LoanDetailData> loanDetailList = [];

  @override
  void onInit() {

    super.onInit();
    getLoanList();
  }

  void startLoading() {
    loading = true;
    update();
  }

  void stopLoading() {
    loading = false;
    update();
  }

  getLoanList() async {
    startLoading();
    try {
      var response = await LoanApi.getMyApplyLoan(authToken: sharePref.getString(authToken) ?? '', userId: sharePref.getString(userId) ?? '');
      LoanDetail loanDetail = LoanDetail.fromJson(json.decode(response.data));

      print("Response LoanDetail => : $response");

      if (response.statusCode == 200) {
        if (loanDetail.success == true) {
          loanDetailList.clear();
          loanDetailList.addAll((loanDetail?.data)!.map((x) => LoanDetailData.fromJson(x.toJson())).toList());
          update();
          stopLoading();
        } else {
          stopLoading();
          GetSnackbar(supTitle: loanDetail.message.toString(), title: "Error");
        }
      } else {
        stopLoading();
        GetSnackbar(supTitle: loanDetail.message.toString(), title: "Error");
      }
    } catch (e) {
      print("Error : ${e.toString()}");
      stopLoading();
      GetSnackbar(supTitle: '', title: "Oops! Something went wrong.");
    }
  }
}

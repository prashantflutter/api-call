import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/get_snackbar.dart';
import '../../employee_screen/model/loan/loan_apply.dart';
import '../../employee_screen/model/loan/loan_duration.dart';
import '../../services/loan_services.dart';
import '../../utils/constant/app_string.dart';
import '../../utils/sharPreferenceUtils.dart';

class LoanApplyController extends GetxController {
  var sharePref = SharedPrefs.instance;
  bool loading = false;
  bool loadingLoanApply = false;
  List<LoanDurationData> loanDurationList = [];
  var chosenValue;

  final startDateController = TextEditingController();
  final endDateController = TextEditingController();
  var loanOptionId;
  var loanOptionName;
  var id;
  var loanAmount;
  DateTime initialDate = DateTime.now();

  final loanTypeController = TextEditingController();
  var clientNameController = TextEditingController();
  var loanAmountController = TextEditingController();

  var employeeName;

  @override
  void onInit() {
    if (Get.arguments[0] == "Apply") {
      loanOptionId = Get.arguments[1];
      loanOptionName = Get.arguments[2];
    } else {
      loanOptionId = Get.arguments[1];
      loanOptionName = Get.arguments[2];
      id = Get.arguments[3];
      print("List Id : $id");
      loanAmountController.text = Get.arguments[4].toString();
      chosenValue = Get.arguments[5];
      startDateController.text = Get.arguments[6];
      endDateController.text = Get.arguments[7];
    }

    loanTypeController.text = Get.arguments[2];
    startDateController.text = DateTime.now().toString().substring(0, 10);
    endDateController.text = DateTime.now().toString().substring(0, 10);
    clientNameController.text = sharePref.getString(userName) ?? '';

    update();
    getLoanDuration();
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

  void startLoadingLoanApply() {
    loadingLoanApply = true;
    update();
  }

  void stopLoadingLoanApply() {
    loadingLoanApply = false;
    update();
  }

  void dropDownUpdateValue(String value) {
    chosenValue = value;
    int duration = 0;
    loanDurationList.forEachIndexed((element, index) {
      if (loanDurationList[index].id == chosenValue) {
        duration = loanDurationList[index].month!;
        print("Duration : $duration");
      }
      update();
    });

    endDateController.text = DateTime(initialDate.year, initialDate.month + duration, initialDate.day).toString().substring(0, 10);
    update();
  }

  getLoanDuration() async {
    startLoading();
    try {
      var response = await LoanApi.getLoanDuration();
      LoanDuration loanDuration = LoanDuration.fromJson(json.decode(response.data));

      print("Response LoanType => : $response");

      if (response.statusCode == 200) {
        if (loanDuration.success == true) {
          loanDurationList.clear();
          loanDurationList.addAll((loanDuration?.data)!.map((x) => LoanDurationData.fromJson(x.toJson())).toList());
          update();
          stopLoading();
        } else {
          stopLoading();
          GetSnackbar(supTitle: loanDuration.message.toString(), title: "Error");
        }
      } else {
        stopLoading();
        GetSnackbar(supTitle: loanDuration.message.toString(), title: "Error");
      }
    } catch (e) {
      print("Error : ${e.toString()}");
      stopLoading();
      GetSnackbar(supTitle: '', title: "Oops! Something went wrong.");
    }
  }

  selectDate(BuildContext context, String durationId) async {
    int duration = 0;
    var date = await showDatePicker(context: context, initialDate: initialDate, firstDate: DateTime.now(), lastDate: DateTime(2100));
    initialDate = date!;
    startDateController.text = date.toString().substring(0, 10);
    loanDurationList.forEachIndexed((element, index) {
      if (loanDurationList[index].id == durationId) {
        duration = loanDurationList[index].month!;
        print("Duration : $duration");
      }
      update();
    });

    endDateController.text = DateTime(initialDate.year, initialDate.month + duration, initialDate.day).toString().substring(0, 10);
    update();
  }

  loanApply(BuildContext context) async {
    startLoadingLoanApply();
    try {
      var response = await LoanApi.loanApply(
        authToken: sharePref.getString(authToken) ?? '',
        userId: sharePref.getString(userId) ?? '',
        loanOption: loanOptionId.toString(),
        loanDuration: chosenValue,
        amount: loanAmountController.text.trim(),
        startDate: startDateController.text.trim(),
        endDate: endDateController.text.trim(),
      );
      LoanApplyModel loanApplyModel = LoanApplyModel.fromJson(json.decode(response.data));

      print("Response ApplyLoan => : $response");

      if (response.statusCode == 200) {
        if (loanApplyModel.success == true) {
          stopLoadingLoanApply();
          Navigator.of(context).pop();
          GetSnackbar(supTitle: loanApplyModel.message.toString(), title: "Success");
        } else {
          stopLoadingLoanApply();
          GetSnackbar(supTitle: loanApplyModel.message.toString(), title: "Error");
        }
      } else {
        stopLoadingLoanApply();
        GetSnackbar(supTitle: loanApplyModel.message.toString(), title: "Error");
      }
    } catch (e) {
      print("Error : ${e.toString()}");
      stopLoadingLoanApply();
      GetSnackbar(supTitle: '', title: "Oops! Something went wrong.");
    }
  }

  editLoanApply(BuildContext context) async {
    startLoadingLoanApply();
    try {
      var response = await LoanApi.editLoanApply(
        authToken: sharePref.getString(authToken) ?? '',
        userId: sharePref.getString(userId) ?? '',
        loanListId: id.toString(),
        loanOption: loanOptionId.toString(),
        loanDuration: chosenValue,
        amount: loanAmountController.text.trim(),
        startDate: startDateController.text.trim(),
        endDate: endDateController.text.trim(),
      );
      LoanApplyModel loanApplyModel = LoanApplyModel.fromJson(json.decode(response.data));

      print("Response editLoanApply => : $response");

      if (response.statusCode == 200) {
        if (loanApplyModel.success == true) {
          stopLoadingLoanApply();
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          GetSnackbar(supTitle: loanApplyModel.message.toString(), title: "Success");
        } else {
          stopLoadingLoanApply();
          GetSnackbar(supTitle: loanApplyModel.message.toString(), title: "Error");
        }
      } else {
        stopLoadingLoanApply();
        GetSnackbar(supTitle: loanApplyModel.message.toString(), title: "Error");
      }
    } catch (e) {
      print("Error : ${e.toString()}");
      stopLoadingLoanApply();
      GetSnackbar(supTitle: '', title: "Oops! Something went wrong.");
    }
  }
}

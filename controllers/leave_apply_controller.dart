import 'dart:convert';

import 'package:ehubt_finanace_expence/employee_screen/model/leave/leave_apply.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../components/get_snackbar.dart';
import '../../employee_screen/model/leave/leave_type.dart';
import '../../services/leave_api.dart';
import '../../utils/constant/app_string.dart';
import '../../utils/sharPreferenceUtils.dart';

// 2QMXSehDLSmshDmRQcKUIAiQjIZAp1UvKUrjsnewgqSP6F5oBX

class LeaveApplyController extends GetxController {
  var sharePref = SharedPrefs.instance;
  final startDateController = TextEditingController();
  final endDateController = TextEditingController();
  final reasonController = TextEditingController();
  var hintText = DateFormat('yyyy-MM-dd').format(DateTime.now());

  bool loading = false;
  List<LeaveTypeData> leaveTypeList = [];

  var chosenValue;

  bool isFullDay = false;

  var startDate;
  var endDate;

  bool checkStartHalf = false;
  bool checkEndHalf = false;

  var totalLeave = "0";

  @override
  void onInit() {
    getLeaveType();
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

  void dropDownUpdateValue(String value) {
    chosenValue = value;
    update();
  }

  getLeaveType() async {
    startLoading();
    try {
      var response = await LeaveApi.getLeaveTye(
          authToken: sharePref.getString(authToken) ?? '',
          userId: sharePref.getString(userId) ?? '');
      LeaveTypeModel leaveTypeModel = LeaveTypeModel.fromJson(json.decode(response.data));

      print("Response LeaveType => : $response");

      if (response.statusCode == 200) {
        if (leaveTypeModel.success == true) {
          stopLoading();
          leaveTypeList.clear();
          leaveTypeList.addAll((leaveTypeModel?.data)!
              .map((x) => LeaveTypeData.fromJson(x.toJson()))
              .toList());
          update();
        } else {
          stopLoading();
          GetSnackbar(
              supTitle: leaveTypeModel.message.toString(), title: "Error");
        }
      } else {
        stopLoading();
        GetSnackbar(
            supTitle: leaveTypeModel.message.toString(), title: "Error");
      }
    } catch (e) {
      print("Error : ${e.toString()}");
      stopLoading();
      GetSnackbar(supTitle: '', title: "Oops! Something went wrong.");
    }
  }

  selectDate(BuildContext context, String name) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime(2100));
    if (picked != null) if (name == "Start") {
      startDate = picked;
      startDateController.text = DateFormat('yyyy-MM-dd').format(picked);

      if (endDate != null) {
        if (startDate.compareTo(endDate) > 0) {
          startDateController.clear();
          endDateController.clear();
          startDate = null;
          endDate = null;
          totalLeave = "0";
          GetSnackbar(supTitle: 'Please select proper date', title: "Error");
        } else {
          final difference = endDate.difference(startDate).inDays;
          if (difference != null && difference >= 0) {
            halfLeaveCalculation(difference.toDouble() + 1);
          }
        }
      }
    } else if (name == "End") {
      endDate = picked;
      endDateController.text = DateFormat('yyyy-MM-dd').format(endDate);
      if (startDate != null) {
        if (endDate.compareTo(startDate) < 0) {
          startDateController.clear();
          endDateController.clear();
          startDate = null;
          endDate = null;
          totalLeave = "0";
          GetSnackbar(supTitle: 'Please select proper date', title: "Error");
        } else {
          final difference = endDate.difference(startDate).inDays;
          print(difference);
          if (difference != null && difference >= 0) {
            halfLeaveCalculation(difference.toDouble() + 1);
          }
        }
      }
    }
    update();
  }

  halfLeaveCalculation(double difference) {
    if (checkStartHalf == false && checkEndHalf == false) {
      totalLeave = difference.toString();
    } else if (checkStartHalf == true && checkEndHalf == false) {
      var totalValue = difference - 0.5;
      totalLeave = totalValue.toString();
    } else if (checkStartHalf == false && checkEndHalf == true) {
      var totalValue = difference - 0.5;
      totalLeave = totalValue.toString();
    } else if (checkStartHalf == true && checkEndHalf == true) {
      var totalValue = difference - 1;
      if (totalValue < 0) {
        totalValue = 0;
      }
      totalLeave = totalValue.toString();
    }
    update();
  }

  onStartHalfChange(newValue) {
    checkStartHalf = newValue;
    if (newValue) {
      if (totalLeave != "") {
        double total = double.parse(totalLeave);
        totalLeave = (total - 0.5).toString();
      }
    } else {
      if (totalLeave != "") {
        double total = double.parse(totalLeave);
        totalLeave = (total + 0.5).toString();
      }
    }
    update();
  }

  onEndHalfChange(newValue) {
    checkEndHalf = newValue;
    if (checkEndHalf) {
      if (totalLeave != "") {
        double total = double.parse(totalLeave);
        totalLeave = (total - 0.5).toString();
      }
    } else {
      if (totalLeave != "") {
        double total = double.parse(totalLeave);
        totalLeave = (total + 0.5).toString();
      }
    }
    update();
  }

  applyLeave(BuildContext context) async {
    if (chosenValue == null) {
      GetSnackbar(supTitle: 'Select Leave Category', title: "Error");
    } else {
      var startHalfDayLeave;
      var endHalfDayLeave;
      if (checkStartHalf == true) {
        startHalfDayLeave = "1";
      }
      if (checkEndHalf == true) {
        endHalfDayLeave = "1";
      }

      startLoading();
      try {
        var response = await LeaveApi.applyLeave(
            authToken: sharePref.getString(authToken) ?? '',
            userId: sharePref.getString(userId) ?? '',
            leaveTypeId: chosenValue,
            startDate: startDateController.text.toString().trim(),
            endDate: endDateController.text.toString().trim(),
            leaveReason: reasonController.text.toString().trim(),
            startDateHalf: startHalfDayLeave,
            endDateHalf: endHalfDayLeave);
        LeaveApplyModel leaveApplyModel =
            LeaveApplyModel.fromJson(json.decode(response.data));

        print("Response applyLeave => : $response");

        if (response.statusCode == 200) {
          if (leaveApplyModel.success == true) {
            stopLoading();
            Navigator.of(context).pop();
            Navigator.of(context).pop();
            GetSnackbar(
                supTitle: leaveApplyModel.message.toString(), title: "Success");
            update();
          } else {
            stopLoading();
            GetSnackbar(
                supTitle: leaveApplyModel.message.toString(), title: "Error");
          }
        } else {
          stopLoading();
          GetSnackbar(
              supTitle: leaveApplyModel.message.toString(), title: "Error");
        }
      } catch (e) {
        print("Error : ${e.toString()}");
        stopLoading();
        GetSnackbar(supTitle: '', title: "Oops! Something went wrong.");
      }
    }
  }
}

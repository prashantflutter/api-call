import 'dart:convert';


import 'package:ehubt_finanace_expence/employee_screen/model/leave/leave_cancel_model.dart';
import 'package:ehubt_finanace_expence/utils/constant/app_color.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';

import '../../components/get_snackbar.dart';
import '../../employee_screen/model/leave/leave_detail.dart';

import '../../services/leave_api.dart';
import '../../utils/constant/app_string.dart';
import '../../utils/sharPreferenceUtils.dart';

class LeaveController extends GetxController{
  var sharePref = SharedPrefs.instance;
  bool loading = false;
  bool loadingLeave = false;
  List<LeaveData> leaveList = [];

  @override
  void onInit() {
    getLeave();
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

  void startLoadingLeave() {
    loadingLeave = true;
    update();
  }

  void stopLoadingLeave() {
    loadingLeave = false;
    update();
  }

  getLeave() async {
    startLoading();
    try {
      var response = await LeaveApi.getMyLeave(authToken: sharePref.getString(authToken) ?? '', userId: sharePref.getString(userId) ?? '');
      LeaveDetailModel leaveDetailModel = LeaveDetailModel.fromJson(json.decode(response.data));

      print("Response LeaveDetail => : $response");

      if (response.statusCode == 200) {
        if (leaveDetailModel.success == true) {
          leaveList.clear();
          leaveList.addAll((leaveDetailModel?.data)!.map((x) => LeaveData.fromJson(x.toJson())).toList());
          update();
          stopLoading();
        } else {
          stopLoading();
          GetSnackbar(supTitle: leaveDetailModel.message.toString(), title: "Error");
        }
      } else {
        stopLoading();
        GetSnackbar(supTitle: leaveDetailModel.message.toString(), title: "Error");
      }
    } catch (e) {
      print("Error : ${e.toString()}");
      stopLoading();
      GetSnackbar(supTitle: '', title: "Oops! Something went wrong.");
    }
  }

  confirmDelete(BuildContext context,String leaveId) {
  /*  showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: MaterialLocalizations.of(context)
            .modalBarrierDismissLabel,
        barrierColor: Colors.black45,
        transitionDuration: const Duration(milliseconds: 200),
        pageBuilder: (BuildContext buildContext,
            Animation animation,
            Animation secondaryAnimation) {
          return Center(
            child: Container(
              width: MediaQuery.of(context).size.width - 40,
              margin: EdgeInsets.symmetric(horizontal: 30),
              color: Colors.white,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      "Save",
                      style: TextStyle(color: kTitleColor),
                    ),

                  )
                ],
              ),
            ),
          );
        });*/
    showDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text('Alert'),
            content: Text('Are you sure want to cancel leave?'),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    cancelLeave(context,leaveId);
                  },
                  child: Text('Yes')),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); //close Dialog
                },
                child: Text('Close'),
              )
            ],
          );
        });
  }

  cancelLeave(BuildContext context,String leaveId) async {
    // startLoadingLeave();
    LeaveApi.showProgress(context, true);
    try {
      var response = await LeaveApi.cancelLeave(authToken: sharePref.getString(authToken) ?? '', leaveId: leaveId);
      CancelLeaveModel cancelLeaveModel = CancelLeaveModel.fromJson(json.decode(response.data));

      print("Response Cancel Leave => : $response");

      if (response.statusCode == 200) {
        if (cancelLeaveModel.success == true) {
          // stopLoadingLeave();
          LeaveApi.showProgress(context, false);
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          Navigator.of(context).pop();
          GetSnackbar(supTitle: 'Leave cancel successfully', title: "Success");
          update();
          // update();
          // stopLoadingLeave();
        } else {
          // stopLoadingLeave();
          LeaveApi.showProgress(context, false);
          GetSnackbar(supTitle: cancelLeaveModel.message.toString(), title: "Error");
        }
      } else {
        // stopLoadingLeave();
        LeaveApi.showProgress(context, false);
        GetSnackbar(supTitle: cancelLeaveModel.message.toString(), title: "Error");
      }
    } catch (e) {
      print("Error : ${e.toString()}");
      // stopLoading();
      LeaveApi.showProgress(context, false);
      GetSnackbar(supTitle: '', title: "Oops! Something went wrong.");
    }
  }
}
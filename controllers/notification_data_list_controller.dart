import 'dart:convert';

import 'package:ehubt_finanace_expence/services/notification_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';

import '../../components/get_snackbar.dart';
import '../../employee_screen/model/notification/notification_data_list.dart';
import '../../employee_screen/model/notification/notification_delet.dart';
import '../../utils/constant/app_color.dart';
import '../../utils/constant/app_string.dart';
import '../../utils/constant/loading_dialog.dart';
import '../../utils/sharPreferenceUtils.dart';

class NotificationDataListController extends GetxController {
  List<DataModel> notificationList = [];
  bool loading = false;
  var sharePref = SharedPrefs.instance;

  void onInit() {
    print("this is on init");
    notificationDataList();
  }

  void startLoading() {
    loading = true;
    update();
  }

  void stopLoading() {
    loading = false;
    update();
  }

  notificationDataList() async {
    startLoading();
    try {
      var response =
          await NotificationApi.notificationData(authToken: sharePref.getString(authToken) ?? '', userId: sharePref.getString(userId) ?? '');
      print("Response Notification DataList : ${response.toString()}");
      NotificationListModel notificationListModel = NotificationListModel.fromJson(
        jsonDecode(response.data),
      );
      if (response.statusCode == 200) {
        stopLoading();
        if (notificationListModel.success == true) {
          notificationList.clear();
          notificationList.addAll((notificationListModel?.data)!.map((x) => DataModel.fromJson(x.toJson())).toList());
          print("List Count :::::${notificationList.length}");
        } else {
          stopLoading();
          GetSnackbar(supTitle: notificationListModel.message.toString(), title: "Error");
        }
      } else {
        stopLoading();
        GetSnackbar(supTitle: notificationListModel.message.toString(), title: "Error");
      }
    } catch (e) {
      print('Login Error : $e');
      stopLoading();
      GetSnackbar(supTitle: '', title: "Oops! Something went wrong.");
    }
  }

  confirmDelete(BuildContext context, String notificationId, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text('Alert'),
          content: Text('Are you sure want to delete notification?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                deleteNotification(context, notificationId,index);
              },
              child: Text('Delete'),
            )
          ],
        );
      },
    );
  }
  deleteNotification(BuildContext context, String notificationId,int index) async {
    try {
      LoadingDialog.showProgress(context, true);
      var response = await NotificationApi.notificationDelet(authToken: sharePref.getString(authToken) ?? '', notificationsid: notificationId);
      NotificationDelet notificationDelete = NotificationDelet.fromJson(
        json.decode(response.data),
      );
      if (response.statusCode == 200) {
        print("Response:::${response.statusCode}");
        if (notificationDelete.success == true) {
          LoadingDialog.showProgress(context, false);
          notificationList.removeAt(index);
          GetSnackbar(supTitle: 'Notification Deleted successfully', title: "");
          update();
        } else {
          LoadingDialog.showProgress(context, false);
          GetSnackbar(supTitle: notificationDelete.message.toString(), title: "Error");
        }
      } else {
        LoadingDialog.showProgress(context, false);
        GetSnackbar(supTitle: notificationDelete.message.toString(), title: "Error");
      }
    } catch (e) {
      print("Error :$e");

      LoadingDialog.showProgress(context, false);
      GetSnackbar(supTitle: '', title: "Oops! Something went wrong.");

    }
  }

  static Future<void> showProgress(BuildContext buildContext, bool isshowpro) async {
    if (isshowpro) {
      showDialog(
          context: buildContext,
          barrierDismissible: false,
          builder: (_) {
            return Center(
              child: Container(
                width: 80.0,
                height: 80.0,
                decoration: ShapeDecoration(
                  color: kMainColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                  ),
                ),
                child: Center(
                  child: SizedBox(
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    height: 35,
                    width: 35,
                  ),
                ),
              ),
            );
          });
    } else {
      Navigator.of(buildContext).pop();
    }
  }
}

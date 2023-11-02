import 'package:dio/dio.dart';
import 'package:ehubt_finanace_expence/utils/constant/app_color.dart';
import 'package:flutter/material.dart';

import 'baseAPI.dart';

class LeaveApi {
  static getMyLeave({required String authToken, required String userId}) async {
    FormData formData = new FormData.fromMap({"user_id": '$userId'});
    Response response = await BaseAPI.dio.post(
      "/leave_details",
      data: formData,
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ),
    );
    return response;
  }

  static getLeaveTye(
      {required String authToken, required String userId}) async {
    FormData formData = new FormData.fromMap({"user_id": '$userId'});
    Response response = await BaseAPI.dio.post(
      "/leave_types",
      data: formData,
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ),
    );
    return response;
  }

  static applyLeave(
      {required String authToken,
      required String userId,
      required String leaveTypeId,
      required String startDate,
      required String endDate,
      required String leaveReason,
      required startDateHalf,
      required endDateHalf}) async {
    FormData formData = new FormData.fromMap({
      "user_id": '$userId',
      "leave_type_id": '$leaveTypeId',
      "start_date": '$startDate',
      "end_date": '$endDate',
      "leave_reason": '$leaveReason',
      "start_date_half_leave": startDateHalf == null ? '' : '$startDateHalf',
      "end_date_half_leave": endDateHalf == null ? '' : '$endDateHalf'
    });
    Response response = await BaseAPI.dio.post(
      "/apply_leaves",
      data: formData,
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ),
    );
    return response;
  }

  static cancelLeave(
      {required String authToken, required String leaveId}) async {
    FormData formData = new FormData.fromMap({"leave_id": '$leaveId'});
    Response response = await BaseAPI.dio.post(
      "/leave_delete",
      data: formData,
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ),
    );
    return response;
  }

  static Future<void> showProgress(
      BuildContext buildContext, bool isshowpro) async {
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

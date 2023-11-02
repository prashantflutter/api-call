import 'package:dio/dio.dart';

import 'baseAPI.dart';

class NotificationApi {

  static notificationData({required String authToken, required String userId})async{
    FormData formData = new FormData.fromMap({"user_id": '$userId'});
    Response response = await BaseAPI.dio.post(
      "/notifications_list",
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


  static  notificationDelet({required String authToken, required String notificationsid})async{
    FormData formData = new FormData.fromMap({"notifications_id": '$notificationsid'});
    Response response = await BaseAPI.dio.post(
      "/notifications_delete",
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
}
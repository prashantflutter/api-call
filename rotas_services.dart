
import 'package:dio/dio.dart';

import 'baseAPI.dart';

class RotasApi{
  // static getRotas({required String authToken, required String userId}) async {
  //   FormData formData = new FormData.fromMap({"user_id": '$userId'});
  //   Response response = await BaseAPI.dio.post(
  //     "/rotas",
  //     data: formData,
  //     options: Options(
  //       headers: {
  //         'Accept': 'application/json',
  //         'Authorization': 'Bearer $authToken',
  //       },
  //     ),
  //   );
  //   return response;
  // }

  static getRotasWork({required String authToken, required String userId,required String weekStartDate,required String weekEndDate}) async {
    FormData formData = new FormData.fromMap({"user_id": '$userId',"start_date":'$weekStartDate',"end_date":'$weekEndDate'});
    Response response = await BaseAPI.dio.post(
      "/rotas",
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

  static shiftSwapRequest({required String authToken, required String userId,required String currentDate,required String transferDate,required String reason}) async {
    FormData formData = new FormData.fromMap({"user_id": '$userId',"date":'$currentDate',"transfer_date":'$transferDate',"reason":'$reason'});
    Response response = await BaseAPI.dio.post(
      "/rotas-transfer",
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

  static rotasAvailability({required String authToken, required String userId}) async {
    FormData formData = new FormData.fromMap({"user_id": '$userId'});
    Response response = await BaseAPI.dio.post(
      "/rotas-availabilities",
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

  static sendRotasAvailableData({required String authToken, required String userId,required String data}) async {
    FormData formData = new FormData.fromMap({"user_id": '$userId',"data":'$data'});
    Response response = await BaseAPI.dio.post(
      "/send-rotas-availabilities-data",
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
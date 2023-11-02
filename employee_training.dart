import 'package:dio/dio.dart';

import 'baseAPI.dart';

class EmployeeTrainingServices {
  static companyPolicy() async {
    Response response = await BaseAPI.dio.post(
      "/company_policy",
    );
    return response;
  }

  static get_List_of_Announcements({
    required String authToken,
    required String user_id,
  }) async {
    FormData formData = new FormData.fromMap({"user_id": '$user_id'});
    Response response = await BaseAPI.dio.post(
      "/announcements",
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

  static trainingManuals({required String authToken, required String userId}) async {
    FormData formData = new FormData.fromMap(
      {
        "user_id": '$userId',
      },
    );
    Response response = await BaseAPI.dio.post(
      "/training_manuals",
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

  static getMyCourseCertificate({
    required String user_id,
  }) async {
    final Dio _dio = Dio();
    final _baseUrl = '${BaseAPI.baseCourse}ehubt/my_course_certificate';
    FormData formData = new FormData.fromMap({"userID": '$user_id'});
    Response response = await _dio.post(
      _baseUrl,
      data: formData,
      options: Options(
        headers: {'Content-Type': 'application/json', 'X-API-Key': '1234'},
      ),
    );

    return response;
  }

  static getMyCourse({
    required String userId,
  }) async {
    final Dio _dio = Dio();
    final _baseUrl = '${BaseAPI.baseCourse}ehubt/courses';
    FormData formData = new FormData.fromMap({"userID": '$userId'});
    Response response = await _dio.post(
      _baseUrl,
      data: formData,
      options: Options(
        headers: {'Content-Type': 'application/json', 'X-API-Key': '1234'},
      ),
    );

    return response;
  }
}

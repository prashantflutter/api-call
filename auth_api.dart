import 'dart:io';

import 'package:dio/dio.dart';
import '../utils/sharPreferenceUtils.dart';
import 'baseAPI.dart';

class AuthApi {
  final sharedPref = SharedPrefs.instance;

  static login({required String email, required String password, required String companyKey}) async {
    print('Email : $email');
    print('password : $password');
    print('companyKey : $companyKey');

    FormData formData = new FormData.fromMap({"company_key": '$companyKey', "employee_id": '$email', "pin": '$password'});
    Response response = await BaseAPI.dio.post(
      "/join-company",
      data: formData,
    );
    return response;
  }

  static adminLogin({required String email, required String password}) async {
    print('Email : $email');
    print('password : $password');

    FormData formData = new FormData.fromMap({"email": '$email', "password": '$password'});
    Response response = await BaseAPI.dio.post(
      "/company_login",
      data: formData,
    );
    return response;
  }

  static companyVerify({required String companyKey}) async {
    FormData formData = new FormData.fromMap({"key": '$companyKey'});
    Response response = await BaseAPI.dio.post(
      "/check-company-key",
      data: formData,
    );
    return response;
  }

  static employeeProfile({required String authToken, required String userId}) async {
    FormData formData = new FormData.fromMap({"user_id": '$userId'});
    Response response = await BaseAPI.dio.post(
      "/employee_profile",
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

  static termsCondition() async {
    Response response = await BaseAPI.dio.post("/terms_and_conditions");
    return response;
  }

  static notification({required String authToken, required String userId, required String fcmToken,required String uniqueId}) async {
    FormData formData = new FormData.fromMap({"user_id": '$userId', "fcm_token": '$fcmToken',"unique_token_id":'$uniqueId'});

    Response response = await BaseAPI.dio.post(
      "/store_fcm_token",
      data: formData,
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ),
    );
    print("this is formdata::::${authToken}");
    return response;
  }

  static notificationAdmin({required String authToken, required String userId, required String fcmToken,required String uniqueId}) async {
    FormData formData = new FormData.fromMap({"user_id": '$userId', "fcm_token": '$fcmToken',"unique_token_id":'$uniqueId'});

    Response response = await BaseAPI.dio.post(
      "/store_company_fcm_token",
      data: formData,
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ),
    );
    print("this is formdata::::${authToken}");
    return response;
  }

  static logoutEmployee({required String authToken, required String userId,required String uniqueId}) async {
    FormData formData = new FormData.fromMap({"user_id": '$userId',"unique_token_id":'$uniqueId'});

    Response response = await BaseAPI.dio.post(
      "/employee_logout",
      data: formData,
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ),
    );
    print("this is formdata::::${authToken}");
    return response;
  }

  static logoutCompany({required String authToken, required String userId,required String uniqueId}) async {
    FormData formData = new FormData.fromMap({"user_id": '$userId',"unique_token_id":'$uniqueId'});

    Response response = await BaseAPI.dio.post(
      "/company_logout",
      data: formData,
      options: Options(
        headers: {
          'Accept': 'application/json',
          'Authorization': 'Bearer $authToken',
        },
      ),
    );
    print("this is formdata::::${authToken}");
    return response;
  }

  static editProfile({
    required String authToken,
    required String userId,
    required String fullName,
    required String email,
    required String address,
    required String gender,
    required File image,
  }) async {
    FormData formData;
    formData = image.path != ""
        ? new FormData.fromMap({
            "user_id": '$userId',
            "full_name": '$fullName',
            "email": "$email",
            "address": "$address",
            "gender": "$gender",
            "image": image.path != "" ? await MultipartFile.fromFile(image.path) : '',
          })
        : FormData.fromMap({
            "user_id": '$userId',
            "full_name": '$fullName',
            "email": "$email",
            "address": "$address",
            "gender": "$gender",
          });
    print("this is edit profile screen");
    Response response = await BaseAPI.dio.post(
      "/edit_employee_employee_side",
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


  static getAdminProfile({required String authToken, required String user_id}) async {
    FormData formData = new FormData.fromMap({"user_id": '$user_id'});
    Response response = await BaseAPI.dio.post(
      "/company_profile",
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

  static AdminEditProfile({
    required String authToken,
    required String userId,
    required String comapnyName,
    required String fristName,
    required String lastName,
    required String email,
    required File image,
  }) async {
    FormData formData;
    formData = image.path != ""
        ? new FormData.fromMap({
      "user_id": '$userId',
      "name": '$comapnyName',
      "email": "$email",
      "firstname": "$fristName",
      "lastname": "$lastName",
      "image": image.path != "" ? await MultipartFile.fromFile(image.path) : '',
    })
        : FormData.fromMap({
      "user_id": '$userId',
      "name": '$comapnyName',
      "email": "$email",
      "firstname": "$fristName",
      "lastname": "$lastName",
    });
    Response response = await BaseAPI.dio.post(
      "/edit_company_profile",
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

  static changepassword(
      {required String authToken, required String userId, required String currentpassword, required String newpassword, required String confirmpassword}) async {
    FormData formData = new FormData.fromMap(
        {"user_id": '$userId', "current_password": "$currentpassword", "new_password": "$newpassword", "confirm_password": "$confirmpassword"});
    Response response = await BaseAPI.dio.post(
      "/edit_company_password",
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

  static chatBot({required String text}) async {
    Dio dio = new Dio();
    FormData formData = FormData.fromMap({"query": '$text'});
    Response response = await dio.post(
      "http://5.161.190.89:5000/query",
      data: formData,
    );
    print("this is response:::::$response");
    return response;
  }

  static employeeVideoPlay() async {
    Response response = await BaseAPI.dio.post(
      "/employee_help_videos",
      options: Options(),
    );
    return response;
  }

}

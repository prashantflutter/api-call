import 'package:dio/dio.dart';

import 'baseAPI.dart';

class PayrollServices {
  static getPayrollServices({required String authToken, required String userId, required String monthYear}) async {
    FormData formData = new FormData.fromMap({"user_id": '$userId', "month_year": '$monthYear'});
    Response response = await BaseAPI.dio.post(
      "/employee_payrolls",
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

  static getDetailPayrollServices({required String authToken, required String id, required String userId}) async {
    FormData formData = FormData.fromMap({"id": '$id', "user_id": '$userId'});
    Response response = await BaseAPI.dio.post(
      "/payslip_statement_details",
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

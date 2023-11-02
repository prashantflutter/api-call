import 'package:dio/dio.dart';

import 'baseAPI.dart';

class LoanApi {
  static getMyApplyLoan({required String authToken, required String userId}) async {
    FormData formData = new FormData.fromMap({"user_id": '$userId'});
    Response response = await BaseAPI.dio.post(
      "/loan-details",
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

  static getLoanType({required String authToken, required String userId}) async {
    FormData formData = new FormData.fromMap({"user_id": '$userId'});
    Response response = await BaseAPI.dio.post(
      "/loan-options",
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

  static getLoanDuration() async {
    Response response = await BaseAPI.dio.post("/loan-duration");
    return response;
  }

  static loanApply(
      {required String authToken,
      required String userId,
      required String loanOption,
      required String loanDuration,
      required String amount,
      required String startDate,
      required String endDate}) async {
    FormData formData = new FormData.fromMap({
      "user_id": '$userId',
      "loan_option": '$loanOption',
      "loan_duration": '$loanDuration',
      "amount": '$amount',
      "start_date": '$startDate',
      "end_date": '$endDate'
    });
    Response response = await BaseAPI.dio.post(
      "/loan-apply",
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

  static editLoanApply(
      {required String authToken,
        required String userId,
        required String loanListId,
        required String loanOption,
        required String loanDuration,
        required String amount,
        required String startDate,
        required String endDate}) async {
    FormData formData = new FormData.fromMap({
      "list_id":'$loanListId',
      "user_id": '$userId',
      "loan_option": '$loanOption',
      "loan_duration": '$loanDuration',
      "amount": '$amount',
      "start_date": '$startDate',
      "end_date": '$endDate'
    });
    Response response = await BaseAPI.dio.post(
      "/loan-edit",
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

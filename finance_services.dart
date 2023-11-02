import 'package:dio/dio.dart';

import 'baseAPI.dart';

class FinanceApi {
  static getBranchList({required String authToken, required String userId, required String type}) async {
    FormData formData = new FormData.fromMap({"user_id": '$userId', "type": '$type',"sale_expense_use":'1'});
    Response response = await BaseAPI.dio.post(
      "/branch_list",
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

  static getExpenseList({required String authToken, required String userId, required String branchId, required String groupId}) async {
    FormData formData = new FormData.fromMap({"user_id": '$userId', "branch_id": '$branchId', "group_id": '$groupId'});

    Response response = await BaseAPI.dio.post(
      "/expenses_list_branch_wise",
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

  static storeExpense(
      {required String authToken,
      required String userId,
      required String amount,
      required String expenseId,
      required String taxAmount,
      required String totalAmount,
      required String selectDate,
      required String comment,
      required String expenseListID,
      required String imageList}) async {
    FormData formData = new FormData.fromMap({
      "user_id": '$userId',
      "amount": '$amount',
      "expense_id": '$expenseId',
      "tax_amount": '$taxAmount',
      "total_amount": '$totalAmount',
      "date": '$selectDate',
      "expense_list_id": '$expenseListID',
      "comments": '$comment',
      "image": '$imageList'
    });

    Response response = await BaseAPI.dio.post(
      "/store_expense",
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

  static getUSerExpense({required String authToken, required String userId, required String filterType}) async {
    FormData formData = new FormData.fromMap({"user_id": '$userId', "date_range": '$filterType'});
    Response response = await BaseAPI.dio.post(
      "/show_user_expenses_list",
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

  static getExpenseGraph({required String authToken, required String userId}) async {
    FormData formData = new FormData.fromMap({"user_id": '$userId'});
    Response response = await BaseAPI.dio.post(
      "/expense_data_for_chart",
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

  static getUserSalesListAdded({required String authToken, required String userId, required String date_range}) async {
    FormData formData = new FormData.fromMap({"user_id": '$userId', "date_range": '$date_range'});

    print('userId ${userId} = date_range ${date_range} ');

    Response response = await BaseAPI.dio.post(
      "/show_user_sales_list",
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

  static getSaleChartDataList({required String authToken, required String userId}) async {
    FormData formData = new FormData.fromMap({"user_id": '$userId'});

    print('userId ${userId} ');

    Response response = await BaseAPI.dio.post(
      "/sale_data_for_chart",
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

  static getSalesStoreList(
      {required String authToken,
      required String userId,
      required String sale_id,
      required String amount,
      required String date,
      required String comments,
      required String sales_list_id}) async {
    FormData formData = new FormData.fromMap(
        {"user_id": '$userId', "sale_id": sale_id, "amount": '$amount', "date": '$date', "comments": '$comments', "sales_list_id": '$sales_list_id'});

    print('userId ${userId} = sale_id ${sale_id} = amount ${amount} = date ${date} = comments ${comments}  =  sales_list_id ${sales_list_id}');
    Response response = await BaseAPI.dio.post(
      "/store_sales",
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

  static getSalesList({required String authToken, required String userId, required String branchId, required String groupId}) async {
    FormData formData = new FormData.fromMap({"user_id": '$userId', "branch_id": '$branchId', "group_id": '$groupId'});

    Response response = await BaseAPI.dio.post(
      "/sales_list_branch_wise",
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

import 'dart:convert';

import 'package:ehubt_finanace_expence/services/finance_services.dart';


import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/get_snackbar.dart';

import '../../employee_screen/model/finance/expense_graph_detail_model.dart';


import '../../utils/constant/app_string.dart';
import '../../utils/sharPreferenceUtils.dart';

class ExpenseController extends GetxController {
  bool loading = false;

  var sharePref = SharedPrefs.instance;
  List<ExpenseGraphData> expenseGraphList = [];

  List<GraphExpense> data = [];

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    _init();
    super.onReady();
  }

  void startLoading() {
    loading = true;
    update();
  }

  void stopLoading() {
    loading = false;
    update();
  }

  _init(){
    if(sharePref.getString('isExpenseAdd') != "0"){
      getExpenseGraphData();
    }else{
      GetSnackbar(supTitle: '"You are not eligible to add or see Expanses, Please contact to admin or support if any Problem"', title: "Error");
    }
  }

  getExpenseGraphData() async {
    startLoading();
    try {
      var response = await FinanceApi.getExpenseGraph(authToken: sharePref.getString(authToken) ?? '', userId: sharePref.getString(userId) ?? '');
      ExpenseGraphDetailModel expenseGraphDetailModel = ExpenseGraphDetailModel.fromJson(json.decode(response.data));

      print("Response Expense GraphData => : $response");

      if (response.statusCode == 200) {
        if (expenseGraphDetailModel.success == true) {
          expenseGraphList.clear();
          data.clear();
          expenseGraphList.addAll((expenseGraphDetailModel?.data)!.map((x) => ExpenseGraphData.fromJson(x.toJson())).toList());
          update();
          expenseGraphList.forEach((element) {
            data.add(GraphExpense(
                DateTime(DateTime.parse(element.date!).year, DateTime.parse(element.date!).month, DateTime.parse(element.date!).day),
                element.total != null ? element.total.toDouble() : 0.0));
          });
          stopLoading();
        } else {
          stopLoading();
          GetSnackbar(supTitle: expenseGraphDetailModel.message.toString(), title: "Error");
        }
      } else {
        stopLoading();
        GetSnackbar(supTitle: expenseGraphDetailModel.message.toString(), title: "Error");
      }
    } catch (e) {
      print("Error : ${e.toString()}");
      stopLoading();
      GetSnackbar(supTitle: '', title: "Oops! Something went wrong.");
    }
  }

  @override
  void dispose() {
    // Get.delete<ExpenseController>();
    super.dispose();
  }

}

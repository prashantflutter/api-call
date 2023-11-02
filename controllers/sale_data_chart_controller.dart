import 'dart:convert';

import 'package:ehubt_finanace_expence/employee_screen/model/finance/sale_data_chart_model.dart';
import 'package:ehubt_finanace_expence/services/finance_services.dart';
import 'package:get/get.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../utils/constant/app_string.dart';
import '../../utils/sharPreferenceUtils.dart';

class SaleDataChartController extends GetxController {
  bool loading = false;
  var sharePref = SharedPrefs.instance;
  var weekStartDate = '';
  var weekEndDate = '';
  var totalWeekHour = '0.0';
  List<SaleChartDataList> saleChartDataList = [];

  List<GraphSales> data = [];

  @override
  void onInit() {
    // showSaleChartData();
    super.onInit();
  }

  void startLoading() {
    loading = true;
    update();
  }

  void stopLoading() {
    loading = false;
    update();
  }

  showSaleChartData() async {
    startLoading();
    try {
      var response =
          await FinanceApi.getSaleChartDataList(authToken: sharePref.getString(authToken) ?? '', userId: sharePref.getString(userId) ?? '');

      SaleDataChartModel saleDataChartModel = SaleDataChartModel.fromJson(json.decode(response.data));

      if (response.statusCode == 200) {
        print('Sale Chart Data Response : $response');
        if (saleDataChartModel.success == true) {
          saleChartDataList.clear();
          data.clear();
          saleChartDataList.addAll((saleDataChartModel.data!).map((e) => SaleChartDataList.fromJson(e.toJson())).toList());
          update();
          saleChartDataList.forEach((element) {
            data.add(GraphSales(DateTime(DateTime.parse(element.date!).year, DateTime.parse(element.date!).month, DateTime.parse(element.date!).day),
                element.total != null ? element.total.toDouble() : 0.0));
          });
          update();
          stopLoading();

        } else {
          print('Sale Chart Data Response Model : Failed to connect');
        }
      } else {
        print('Sale Chart Data Response  : Failed to connect');
      }
    } catch (e) {
      print('error : $e');
    }
  }
}

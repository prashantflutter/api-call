import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';
import '../../components/dropdown_text_filed/dropdown_textfield.dart';
import '../../components/get_snackbar.dart';
import '../../employee_screen/model/finance/branch_list_model.dart';
import '../../employee_screen/model/finance/salesStoreModel.dart';
import '../../employee_screen/model/finance/sales_list_model.dart';
import '../../employee_screen/screens/finance_main_screen/finance_main_screen.dart';
import '../../services/finance_services.dart';
import '../../utils/constant/app_string.dart';
import '../../utils/sharPreferenceUtils.dart';
import 'sale_data_chart_controller.dart';

class SalesController extends GetxController {
  bool loading = false;
  bool loadingExpense = false;
  var sharePref = SharedPrefs.instance;

  List<BranchData> branchList = [];
  List<Groups> groupList = [];


  var branchListController = SingleValueDropDownController();
  List<DropDownValueModel> dropDownBranchList = [];

  var groupListController = SingleValueDropDownController();
  List<DropDownValueModel> dropDownGroupList = [];


  List<SalesListData> salesListData = [];

  var chosenValue;
  var chosenGroupValue;


  var hintText = DateFormat('yyyy-MM-dd').format(DateTime.now());


  var amountController = TextEditingController();
  var commissionPaidController = TextEditingController();
  var commissionTextClaimController = TextEditingController();
  var taxController = TextEditingController();
  var netAmountController = TextEditingController();

  var selectDateController = TextEditingController();
  var commentController = TextEditingController();



  @override
  void onInit() {
    _init();
    branchList.clear();
    dropDownBranchList.clear();
    selectDateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    super.onInit();
  }

  void _init() {
    print("Main Method Call");
  }

  void startLoading() {
    loading = true;
    update();
  }

  void stopLoading() {
    loading = false;
    update();
  }

  void startLoadingSales() {
    loadingExpense = true;
    update();
  }

  void stopLoadingSales() {
    loadingExpense = false;
    update();
  }

  // void dropDownUpdateValue(String value) {
  //   chosenValue = value;
  //   update();
  //   getSalesList(chosenValue);
  // }

  void dropDownUpdateValue(String value) {
    chosenValue = value;
    update();
    // getExpenseList(chosenValue);
  }

  void dropDownUpdateValueGroup(String value) {
    chosenGroupValue = value;
    update();
    // getExpenseList(chosenValue);
  }

  getBranchList() async {
    startLoading();
    try {
      var response = await FinanceApi.getBranchList(authToken: sharePref.getString(authToken) ?? '', userId: sharePref.getString(userId) ?? '',type: '2');
      BranchListModel branchListModel = BranchListModel.fromJson(json.decode(response.data));

      print("Response BranchList => : $response");

      if (response.statusCode == 200) {
        if (branchListModel.success == true) {
          stopLoading();
          branchList.clear();
          dropDownBranchList.clear();
          groupList.clear();
          dropDownGroupList.clear();
          branchList.addAll((branchListModel?.data)!.map((x) => BranchData.fromJson(x.toJson())).toList());

          branchList.forEach((element) {
            dropDownBranchList.add(DropDownValueModel(name: element.name!, value: element.id));
          });
          groupList.addAll((branchListModel?.groups)!.map((y) => Groups.fromJson(y.toJson())).toList());

          groupList.forEach((element) {
            dropDownGroupList.add(DropDownValueModel(name: element.name!, value: element.id));
          });
          update();
        } else {
          stopLoading();
          GetSnackbar(supTitle: branchListModel.message.toString(), title: "Error");
        }
      } else {
        stopLoading();
        GetSnackbar(supTitle: branchListModel.message.toString(), title: "Error");
      }
    } catch (e) {
      print("Error : ${e.toString()}");
      stopLoading();
      GetSnackbar(supTitle: '', title: "Oops! Something went wrong.");
    }
  }

  getSalesList() async {
    if(chosenValue == null){
      GetSnackbar(supTitle: 'Please select branch', title: "Error");
    }else if(chosenGroupValue == null){
      GetSnackbar(supTitle: 'Please select group', title: "Error");
    }else {
      print("choose Value : $chosenValue");
      print("choose Group Value : $chosenGroupValue");
      startLoadingSales();
      try {
        var response = await FinanceApi.getSalesList(authToken: sharePref.getString(authToken) ?? '', userId: sharePref.getString(userId) ?? '', branchId: chosenValue,groupId:chosenGroupValue);
        SalesListModel salesListModel = SalesListModel.fromJson(json.decode(response.data));
        print("Response SalesList => : $response");
        if (response.statusCode == 200) {
          if (salesListModel.success == true) {
            stopLoadingSales();
            salesListData.clear();
            salesListData.addAll((salesListModel?.data)!.map((x) => SalesListData.fromJson(x.toJson())).toList());
            update();
          } else {
            stopLoadingSales();
            GetSnackbar(supTitle: salesListModel.message.toString(), title: "Error");
          }
        } else {
          stopLoadingSales();
          GetSnackbar(supTitle: salesListModel.message.toString(), title: "Error");
        }
      } catch (e) {
        print("Error : ${e.toString()}");
        stopLoadingSales();
        GetSnackbar(supTitle: '', title: "Oops! Something went wrong.");
      }
    }
  }

  commission_Paid(String tax_in, int commissionValue, String TaxClaimPercentage, String taxAmountOrPercentage,String exclusiveInclusive) {




    var commissionPaid = (int.parse(amountController.text.toString().isNotEmpty ? amountController.text.toString() : '0') * commissionValue) / 100;
    commissionPaidController.text = commissionPaid.toString();

    update();

      var commissionTextClaim =  (double.parse(commissionPaidController.text.toString().isNotEmpty ? commissionPaidController.text.toString() : '0') * TaxClaimPercentage.toDouble()) / 100;
      commissionTextClaimController.text = commissionTextClaim.toString();

      update();



    if(tax_in == "1"){
      if(exclusiveInclusive == 'inclusive'){
        var temp1 = (double.parse(amountController.text.toString().isNotEmpty ? amountController.text.toString() : '0') - ((double.parse(amountController.text.toString().isNotEmpty ? amountController.text.toString() : '0')) * 100 / (taxAmountOrPercentage.toDouble() + 100)));
        print("Temp1:$temp1");
        taxController.text = temp1.toStringAsFixed(2);


      }else{
        var taxAmount = (double.parse(amountController.text.toString().isNotEmpty ? amountController.text.toString() : '0')) * taxAmountOrPercentage.toDouble() / 100;
        taxController.text = taxAmount.toStringAsFixed(2);
      }
    }else{
      taxController.text = taxAmountOrPercentage.toString();
    }

    update();
    var tempVal = (double.parse(amountController.text.toString().isNotEmpty ? amountController.text.toString() : '0') - double.parse(commissionPaidController.text.toString().isNotEmpty ? commissionPaidController.text.toString() : '0'));
    var totalNetAmount = (tempVal - double.parse(taxController.text.toString().isNotEmpty ? taxController.text.toString() : '0'));

    netAmountController.text = totalNetAmount.toStringAsFixed(2);

    update();

  }




  selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime.now());
    if (picked != null) selectDateController.text = DateFormat('yyyy-MM-dd').format(picked);

    update();
  }

  showSalesStore(int list_id, BuildContext context,String salesId) async {
    final SaleDataChartController saleDataChartController = Get.put(SaleDataChartController());
    final MyTabController tabController = Get.put(MyTabController());
    startLoading();
    try {
      var response = await FinanceApi.getSalesStoreList(
        userId: sharePref.getString(userId) ?? '',
        authToken: sharePref.getString(authToken) ?? '',
        sale_id: salesId,
        amount: amountController.text.toString().trim(),
        date: selectDateController.text.toString().trim(),
        comments: commentController.text.toString().trim(),
        sales_list_id: '0',
      );
      print(' SalesStore Response : ${response.toString()}');
      StoreSalesModel storeSalesModel = StoreSalesModel.fromJson(json.decode(response.data));

      if (response.statusCode == 200) {
        if (storeSalesModel.success == true) {
          startLoading();


          amountController.clear();
          commissionPaidController.clear();
          commissionTextClaimController.clear();
          taxController.clear();
          netAmountController.clear();
          commentController.clear();

          GetSnackbar(supTitle: storeSalesModel.message.toString(), title: "Success");

          Navigator.of(context).pop(true);

          tabController.controller.index = 1;
          update();
          saleDataChartController.showSaleChartData();

        } else {
          startLoading();
          GetSnackbar(supTitle: storeSalesModel.message.toString(), title: "Error");

        }
      } else {
        startLoading();
        GetSnackbar(supTitle: storeSalesModel.message.toString(), title: "Error");

      }
    } catch (e) {
      print('error : $e');
      startLoading();
      GetSnackbar(supTitle: '', title: "Oops! Something went wrong.");
    }
  }
}

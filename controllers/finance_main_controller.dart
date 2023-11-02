import 'dart:convert';
import 'dart:io';

// import 'package:aws3_bucket/aws3_bucket.dart';
// import 'package:aws3_bucket/iam_crediental.dart';
// import 'package:aws3_bucket/image_data.dart';

import 'package:ehubt_finanace_expence/services/finance_services.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:multi_image_picker_view/multi_image_picker_view.dart';

import '../../aws_s3_upload.dart';
import '../../components/dropdown_text_filed/dropdown_textfield.dart';
import '../../components/get_snackbar.dart';
import '../../dospace/dospace_bucket.dart';
import '../../dospace/dospace_spaces.dart';
import '../../employee_screen/model/finance/branch_list_model.dart';
import '../../employee_screen/model/finance/expense_list_model.dart';

import '../../employee_screen/model/finance/store_expense_model.dart';

import '../../employee_screen/screens/finance_main_screen/finance_main_screen.dart';
import '../../utils/constant/app_string.dart';
import '../../utils/sharPreferenceUtils.dart';
import 'expense_controller.dart';

class FinanceMainController extends GetxController {
  bool loading = false;
  bool loadingExpense = false;
  var sharePref = SharedPrefs.instance;

  List<BranchData> branchList = [];
  List<Groups> groupList = [];

  List<ExpenseListData> expenseList = [];

  var branchListController = SingleValueDropDownController();
  List<DropDownValueModel> dropDownBranchList = [];

  var groupListController = SingleValueDropDownController();
  List<DropDownValueModel> dropDownGroupList = [];

  var chosenValue;
  var chosenGroupValue;

  var hintText = DateFormat('yyyy-MM-dd').format(DateTime.now());

  var amountController = TextEditingController();
  var taxController = TextEditingController();
  var totalAmountController = TextEditingController();
  var selectDateController = TextEditingController();
  var commentController = TextEditingController();

  final jobRoleCtrl = TextEditingController();

  List<ImageFile> docList = [];

  List<String> uploadDocList = [];

  @override
  void onInit() {
    branchList.clear();
    dropDownBranchList.clear();
    selectDateController.text = DateFormat('yyyy-MM-dd').format(DateTime.now());
    update();
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

  void startLoadingExpense() {
    loadingExpense = true;
    update();
  }

  void stopLoadingExpense() {
    loadingExpense = false;
    update();
  }

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
      var response =
          await FinanceApi.getBranchList(authToken: sharePref.getString(authToken) ?? '', userId: sharePref.getString(userId) ?? '', type: '1');
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

  getExpenseList() async {
    if (chosenValue == null) {
      GetSnackbar(supTitle: 'Please select branch', title: "Error");
    } else if (chosenGroupValue == null) {
      GetSnackbar(supTitle: 'Please select group', title: "Error");
    } else {
      print("choose Value : $chosenValue");
      print("choose Group Value : $chosenValue");
      startLoadingExpense();
      try {
        var response = await FinanceApi.getExpenseList(
            authToken: sharePref.getString(authToken) ?? '',
            userId: sharePref.getString(userId) ?? '',
            branchId: chosenValue.toString(),
            groupId: chosenGroupValue.toString());
        ExpenseListModel expenseListModel = ExpenseListModel.fromJson(json.decode(response.data));

        print("Response ExpenseList => : $response");

        if (response.statusCode == 200) {
          if (expenseListModel.success == true) {
            stopLoadingExpense();
            expenseList.clear();
            expenseList.addAll((expenseListModel?.data)!.map((x) => ExpenseListData.fromJson(x.toJson())).toList());
            update();
          } else {
            stopLoadingExpense();
            GetSnackbar(supTitle: expenseListModel.message.toString(), title: "Error");
          }
        } else {
          stopLoadingExpense();
          GetSnackbar(supTitle: expenseListModel.message.toString(), title: "Error");
        }
      } catch (e) {
        print("Error : ${e.toString()}");
        stopLoadingExpense();
        GetSnackbar(supTitle: '', title: "Oops! Something went wrong.");
      }
    }
  }

  calculateTax(String isIncludingText) {
    if (isIncludingText == '1') {
      var tax = (int.parse(amountController.text.toString().isNotEmpty ? amountController.text.toString() : '0') *
              int.parse(taxController.text.toString().isNotEmpty ? taxController.text.toString() : '0')) /
          100;
      totalAmountController.text = (int.parse(amountController.text.toString()) + tax).toString();
      update();
    } else {
      var totalAmount = int.parse(amountController.text.toString().isNotEmpty ? amountController.text.toString() : '0') +
          int.parse(taxController.text.toString().isNotEmpty ? taxController.text.toString() : '0');
      totalAmountController.text = totalAmount.toString();
      update();
    }
  }

  selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime.now());
    if (picked != null) selectDateController.text = DateFormat('yyyy-MM-dd').format(picked);
    update();
  }

  storeExpense(BuildContext context, String expenseId) async {
    final ExpenseController expenseController = Get.put(ExpenseController());
    final MyTabController tabController = Get.put(MyTabController());

    startLoadingExpense();
    try {
      if (sharePref.getString('uploadOrNot') == '1') {
        var regionName = sharePref.getString('docRegionNameEmployee') ?? '';
        var bucketName = sharePref.getString('docBucketNameEmployee') ?? '';
        var accessKey = sharePref.getString('docAccessKeyEmployee') ?? '';
        var secretKey = sharePref.getString('docSecretKeyEmployee') ?? '';


        print("Region Name : $regionName");
        print("Bucket Name : $bucketName");
        print("Access Key : $accessKey");
        print("Secret Key : $secretKey");



        uploadDocList.clear();

        if (sharePref.getString('uploadServerName') == 'aws') {
          for (int i = 0; i < docList.length; i++) {
            var fileName = DateTime.now().millisecondsSinceEpoch.toString() + ".${docList[i].path!.split('.').last.replaceAll(" ", "")}";
            AwsS3.uploadFile(
                accessKey: accessKey,
                secretKey: secretKey,
                file: File(docList[i].path!),
                bucket: bucketName,
                region: regionName,
                filename: fileName
                // optional
                );

            uploadDocList.add("https://$bucketName.s3.$regionName.amazonaws.com/$fileName");
          }

          startLoadingExpense();
        } else {
          for (int i = 0; i < docList.length; i++) {
            Spaces spaces = new Spaces(
              region: '$regionName',
              accessKey: '$accessKey', //In Backend Filed Name is Digital Ocean - Access Key
              secretKey: '$secretKey', //In Backend Filed Name is Digital Ocean - Secret Key
            );

            String file_name = DateTime.now().millisecondsSinceEpoch.toString() + ".${docList[i].path!.split('.').last.replaceAll(" ", "")}";

            print("Test Data : ${Permissions.public}");
            var response = await spaces.bucket('$bucketName').uploadFile(file_name, File(docList[i].path!), '*/*', Permissions.public);
            print("File Name: ${file_name}");
            uploadDocList.add("https://$bucketName.$regionName.cdn.digitaloceanspaces.com/${file_name}");
            await spaces.close();
          }
          startLoadingExpense();
        }
      }
    } catch (error) {
      print("Error : $error");
      stopLoadingExpense();
    }

    print("Image List : $uploadDocList");
    var uploadListDoc = uploadDocList.join(', ');

    update();
    print("Image List : $uploadListDoc");

    print("choose Value : $chosenValue");

    startLoadingExpense();
    try {
      var response = await FinanceApi.storeExpense(
        authToken: sharePref.getString(authToken) ?? '',
        userId: sharePref.getString(userId) ?? '',
        amount: amountController.text.toString().trim(),
        expenseId: expenseId,
        taxAmount: taxController.text.toString().trim(),
        totalAmount: totalAmountController.text.toString().trim(),
        selectDate: selectDateController.text.toString().trim(),
        comment: commentController.text.toString().trim(),
        expenseListID: '0',
        imageList: uploadDocList.join(', '),
      );
      StoreExpenseModel storeExpenseModel = StoreExpenseModel.fromJson(json.decode(response.data));

      print("Response ExpenseList => : $response");

      if (response.statusCode == 200) {
        if (storeExpenseModel.success == true) {
          stopLoadingExpense();
          GetSnackbar(supTitle: storeExpenseModel.message.toString(), title: "Success");
          amountController.clear();
          taxController.clear();
          totalAmountController.clear();
          selectDateController.clear();
          commentController.clear();

          Navigator.of(context).pop();
          tabController.controller.index = 0;
          expenseController.getExpenseGraphData();
          update();
        } else {
          stopLoadingExpense();
          GetSnackbar(supTitle: storeExpenseModel.message.toString(), title: "Error");
        }
      } else {
        stopLoadingExpense();
        GetSnackbar(supTitle: storeExpenseModel.message.toString(), title: "Error");
      }
    } catch (e) {
      print("Error : ${e.toString()}");
      stopLoadingExpense();
      GetSnackbar(supTitle: '', title: "Oops! Something went wrong.");
    }
  }
}

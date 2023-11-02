// import 'package:flutter/material.dart';
// import 'package:flutter/src/widgets/framework.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:month_year_picker/month_year_picker.dart';
//
// class SalaryStatementController extends GetxController {
//   var selectedMonth = 'Select Month';
//
//   @override
//   void onInit() {
//     super.onInit();
//   }
//
//   onPressed({required BuildContext context, String? locale}) async {
//     final localeObj = locale != null ? Locale(locale) : null;
//     final selected = await showMonthYearPicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(2020),
//       lastDate: DateTime(2050),
//       locale: localeObj,
//
//     );
//
//     if (selected != null) {
//       selectedMonth = DateFormat('yyyy-MM').format(selected);
//       print("Selected Month : ${DateFormat('yyyy-MM').format(selected)}");
//       update();
//     }
//   }
// }
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import '../../components/get_snackbar.dart';
import '../../employee_screen/model/employee_payrolls_model/emloyee_detail_payrolls.dart';
import '../../employee_screen/model/employee_payrolls_model/employee_payrolls_model.dart';
import '../../employee_screen/screens/employee_main_screen/payroll_report/salary_statement_screen.dart';
import '../../services/expense_payroll_services.dart';
import '../../utils/constant/app_string.dart';
import '../../utils/sharPreferenceUtils.dart';

class SalaryStatementController extends GetxController {
  var startDate;
  var endDate;
  var salaryMonth;
  var hrRate;
  var workingHr;
  var breakHr;
  var overTime;
  var holidayPay;
  var pension;
  var paidTimeOff;
  var sickPay;
  var bonus;
  var commission;
  var finalHr;
  var deduction;
  var total;
  var status;
  var createdAt;
  var asPerJob;

  var selectedMonth;

  var updateMonth = DateTime.now();
  var sharePref = SharedPrefs.instance;
  bool loading = false;
  List<EmployeeData> employeeList = [];
  List<DetailEmployeePayrollsModel> detailEmployeeList = [];

  void startLoading() {
    loading = true;
    update();
  }

  void stopLoading() {
    loading = false;
    update();
  }

  @override
  void onInit() {
    selectedMonth = DateFormat('yyyy-MM').format(
      DateTime.now(),
    );

    update();
    getEmployeePayrolls(
      DateFormat('yyyy-MM').format(
        DateTime.now(),
      ),
    );
    print("this is employee parasol");
    update();
    super.onInit();
  }

  onPressed({required BuildContext context}) async {
    final selected = await showMonthPicker(
      context: context,
      initialDate: updateMonth,
    );

    if (selected != null) {
      updateMonth = selected;
      selectedMonth = DateFormat('yyyy-MM').format(selected);
      // selected1 = selectedMonth;
      print("Selected Month : ${DateFormat('yyyy-MM').format(selected)}");
      getEmployeePayrolls(selectedMonth);
      // print("this is selcted1 ::::::$selected1");
      update();
    }
  }

  getEmployeePayrolls(String selectedMonth) async {
    startLoading();
    try {
      print("this is after try");
      var response = await PayrollServices.getPayrollServices(
        authToken: sharePref.getString(authToken) ?? '',
        userId: sharePref.getString(userId) ?? '',
        monthYear: selectedMonth,
      );
      EmployeePayrollsModel employeePayrollsModel = EmployeePayrollsModel.fromJson(json.decode(response.data));

      if (response.statusCode == 200) {
        print('Employee Payroll Response : $response');
        if (employeePayrollsModel.success == true) {
          stopLoading();
          employeeList.clear();
          employeeList.addAll((employeePayrollsModel.data!).map((e) => EmployeeData.fromJson(e.toJson())).toList());
          print("This Is List Lenght:::${employeeList.length}");
          update();
        }
        else {
          stopLoading();
          GetSnackbar(supTitle: employeePayrollsModel.message.toString(), title: "Error");
        }
      } else {
        stopLoading();
        GetSnackbar(supTitle: employeePayrollsModel.message.toString(), title: "Error");
      }
    } catch (e) {
      employeeList.clear();
      stopLoading();
      GetSnackbar(supTitle: '', title: "Oops! No Data Available.");
    }
  }

  getDetailEmployeePayrolls(String id) async {
    startLoading();
    try {
      var response = await PayrollServices.getDetailPayrollServices(
        authToken: sharePref.getString(authToken) ?? '',
        id: id,
        userId: sharePref.getString(userId) ?? '',
      );
      DetailEmployeePayrollsModel detailEmployeePayrollsModel = DetailEmployeePayrollsModel.fromJson(jsonDecode(response.data));
      print("This Is Detail response::::${response.statusCode}");
      if (response.statusCode == 200) {
        print("This Is Detail Payrolls Response::::${response.statusCode}");
        if (detailEmployeePayrollsModel.success == true) {
          stopLoading();
          startDate = detailEmployeePayrollsModel.data!.startDate.toString();
          endDate = detailEmployeePayrollsModel.data!.endDate.toString();
          salaryMonth = detailEmployeePayrollsModel.data!.salaryMonth.toString();
          hrRate = detailEmployeePayrollsModel.data!.hrRate.toString();
          workingHr = detailEmployeePayrollsModel.data!.workingHr.toString();
          breakHr = detailEmployeePayrollsModel.data!.breakHr.toString();
          holidayPay = detailEmployeePayrollsModel.data!.holidayPay.toString();
          pension = detailEmployeePayrollsModel.data!.pension.toString();
          paidTimeOff = detailEmployeePayrollsModel.data!.paidtimeoff.toString();
          sickPay = detailEmployeePayrollsModel.data!.sickpay.toString();
          bonus = detailEmployeePayrollsModel.data!.bonus.toString();
          commission = detailEmployeePayrollsModel.data!.commission.toString();
          finalHr = detailEmployeePayrollsModel.data!.finalHr.toString();
          deduction = detailEmployeePayrollsModel.data!.deduction.toString();
          total = detailEmployeePayrollsModel.data!.total.toString();
          status = detailEmployeePayrollsModel.data!.status.toString();
          createdAt = detailEmployeePayrollsModel.data!.createdAt.toString();
          asPerJob = detailEmployeePayrollsModel.data!.asPerJob.toString();

          print("This Is data::::::${detailEmployeePayrollsModel.data!.endDate.toString()}");
          print("This Is Detail Payrolls  success Response::::${detailEmployeePayrollsModel.success}");
          stopLoading();
          update();
        } else {
          stopLoading();
          GetSnackbar(supTitle: 'Something went to Wrong', title: "Error");
        }
      } else {
        stopLoading();
        GetSnackbar(supTitle: 'Something went to Wrong', title: "Error");
      }
    } catch (e) {
      print('Error $e');
      GetSnackbar(supTitle: 'Something went to Wrong ?', title: "Error");
    }
  }
}

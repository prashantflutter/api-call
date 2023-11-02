import 'dart:convert';

import 'package:ehubt_finanace_expence/admin_screen/model/company_login_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../components/get_snackbar.dart';
import '../../model/local_database_model/employee.dart';
import '../../model/user.dart';
import '../../routes/routes.dart';
import '../../services/auth_api.dart';
import '../../services/database_service.dart';
import '../../utils/constant/app_string.dart';
import '../../utils/sharPreferenceUtils.dart';

class AuthController extends GetxController {
  bool isChecked = false;
  String? selectType;
  bool loading = false;
  var sharePref = SharedPrefs.instance;

  var emailController = TextEditingController();
  var passwordController = TextEditingController();

  var adminEmailController = TextEditingController();
  var adminPasswordController = TextEditingController();
  bool isLoginRemember = false;

  final DatabaseService _databaseService = DatabaseService();

  @override
  void onInit() {
    super.onInit();

    emailController.text = sharePref.getString(employeeUserName) ?? '';
    passwordController.text = sharePref.getString(employeePassword) ?? '';

    adminEmailController.text = sharePref.getString(companyEmailAddress) ?? '';
    adminPasswordController.text = sharePref.getString(companyPassword) ?? '';

    update();
  }

  void isRemember() {
    isChecked = !isChecked;
    update();
  }

  void isRememberLogin() {
    isLoginRemember = !isLoginRemember;
    update();
  }

  void startLoading() {
    loading = true;
    update();
  }

  void stopLoading() {
    loading = false;
    update();
  }

  void selectLoginType(String type) {
    selectType = type;
    update();

    if (type == 'Admin') {
      Get.toNamed(Routes.adminLoginScreen);
    } else {
      Get.toNamed(Routes.companyIdAddScreen);
    }
  }

  login({required String email, required String password, required String companyKey}) async {
    final db = await _databaseService.database;
    startLoading();

    try {
      var response = await AuthApi.login(email: email, password: password, companyKey: companyKey);
      print("Response login => : ${response.data}");
      UserModel userModel = UserModel.fromJson(json.decode(response.data));

      if (response.statusCode == 200) {
        stopLoading();

        if (userModel.success == true) {
          if (userModel.data!.gdprStatus == '1') {
            sharePref.setString(authToken, '${userModel.data!.token}');
            sharePref.setString(userId, '${userModel.data!.userId}');
            sharePref.setString(loginType, '${userModel.data!.type}');
            sharePref.setString(jobType, '${userModel.data!.asPerJob}');
            sharePref.setString(userName, '${userModel.data!.userName}');
            sharePref.setString(profilePicture, '${userModel.data!.profilePicture}');
            sharePref.setString(branchId, '${userModel.data!.branchId}');
            sharePref.setString(tabletId, '${userModel.data!.tabletId}');
            sharePref.setBool(isUserLogin, true);

            if (isChecked) {
              sharePref.setString(employeeUserName, '${email.toString().trim()}');
              sharePref.setString(employeePassword, '${password.toString().trim()}');
            }

            var _checkEmp = await _databaseService.checkEmp(userModel!.data!.userId!);
            if (_checkEmp == null) {
              await _databaseService.insertEmployee(
                Employee(
                  userId: userModel.data!.userId != null ? userModel.data!.userId! : '',
                  empCode: userModel.data!.employeeCode != null ? userModel.data!.employeeCode! : '',
                  name: userModel.data!.userName != null ? userModel.data!.userName! : '',
                  branchId: userModel.data!.branchId != null ? userModel.data!.branchId! : '',
                  tabletId: userModel.data!.tabletId != null ? userModel.data!.tabletId! : '',
                  jobType: userModel.data!.asPerJob != null ? userModel.data!.asPerJob! : '',
                ),
              );
            } else {
              await db.rawUpdate('UPDATE employee SET userId = ?,empCode = ?,name = ?,branchId = ?,tabletId = ?,jobType = ? WHERE id = ?', [
                userModel.data!.userId != null ? userModel.data!.userId! : '',
                userModel.data!.employeeCode != null ? userModel.data!.employeeCode! : '',
                userModel.data!.userName != null ? userModel.data!.userName! : '',
                userModel.data!.branchId != null ? userModel.data!.branchId! : '',
                userModel.data!.tabletId != null ? userModel.data!.tabletId! : '',
                userModel.data!.asPerJob != null ? userModel.data!.asPerJob! : '',
                _checkEmp.id
              ]);
            }

            Get.offAllNamed(Routes.employeeHomeScreen);
          } else {
            GetSnackbar(supTitle: 'User not active', title: "Error");
          }
        }
      } else {
        stopLoading();
        GetSnackbar(supTitle: userModel.message.toString(), title: "Error");
      }
    } catch (e) {
      print('Login Error : $e');
      stopLoading();
      GetSnackbar(supTitle: '', title: "Oops! Something went wrong.");
    }
  }

  adminLogin({required String email, required String password}) async {
    startLoading();
    try {
      var response = await AuthApi.adminLogin(email: email, password: password);
      print("Response login => : ${response.data}");
      CompanyLoginModel companyLoginModel = CompanyLoginModel.fromJson(json.decode(response.data));

      if (response.statusCode == 200) {
        stopLoading();

        if (companyLoginModel.success == true) {
          sharePref.setString(companyAuthToken, '${companyLoginModel.data!.token}');
          sharePref.setString(companyUserId, '${companyLoginModel.data!.id}');
          sharePref.setString(companyUserName, '${companyLoginModel.data!.name}');
          sharePref.setString(companyUserFirstName, '${companyLoginModel.data!.firstname}');
          sharePref.setString(companyUserLastName, '${companyLoginModel.data!.lastname}');
          sharePref.setString(companyUserEmail, '${companyLoginModel.data!.email}');
          sharePref.setString(companyProfilePicture, '${companyLoginModel.data!.profilePicture}');
          sharePref.setString(companyRotasUrl, '${companyLoginModel.data!.rotasUrl}');
          sharePref.setString(companyChatUrl, '${companyLoginModel.data!.chatUrl}');
          sharePref.setString(companyMobilePermission, '${companyLoginModel.data!.mobilePermissions}');

          sharePref.setBool(isCompanyUserLogin, true);

          if (isLoginRemember) {
            sharePref.setString(companyEmailAddress, '${email.toString().trim()}');
            sharePref.setString(companyPassword, '${password.toString().trim()}');
          }

          Get.offAllNamed(Routes.adminHomeScreen);
        } else {
          GetSnackbar(supTitle: companyLoginModel.message.toString(), title: "Error");
        }
      } else {
        stopLoading();
        GetSnackbar(supTitle: companyLoginModel.message.toString(), title: "Error");
      }
    } catch (e) {
      print('Login Error : $e');
      stopLoading();
      GetSnackbar(supTitle: '', title: "Oops! Something went wrong.");
    }
  }
}

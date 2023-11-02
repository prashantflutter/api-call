import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:ehubt_finanace_expence/utils/constant/loading_dialog.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../admin_screen/model/admin_profile_model/compnay_profile_model.dart';
import '../../components/get_snackbar.dart';
import '../../employee_screen/model/auth/employee_logout.dart';
import '../../routes/routes.dart';
import '../../services/auth_api.dart';
import '../../utils/constant/app_string.dart';
import '../../utils/sharPreferenceUtils.dart';

class AdminMainController extends GetxController {
  var sharePref = SharedPrefs.instance;
  var profilePic;
  var firstName = '';
  var lastName = '';
  var totalEmployee = '0';
  var totalBranch  = '0';
  var totalFile = '0';

  bool loading = false;

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

  _init() {
    profilePic = sharePref.getString(companyProfilePicture) ?? null;
    firstName = sharePref.getString(companyUserFirstName) ?? '';
    lastName = sharePref.getString(companyUserLastName) ?? '';
    update();
  }



  logout(BuildContext context) async {
    LoadingDialog.showProgress(context, true);
    var uniqueId;
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      uniqueId = androidInfo.id;
    } else if (Platform.isIOS) {
      final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      uniqueId = iosInfo.identifierForVendor!;
    }
    print("uniqueId : $uniqueId");
    try {
      var response = await AuthApi.logoutCompany(
          authToken: sharePref.getString(authToken) ?? '', userId: sharePref.getString(userId) ?? '', uniqueId: uniqueId);
      EmployeeLogoutModel employeeLogoutModel = EmployeeLogoutModel.fromJson(json.decode(response.data));
      print("Employee Logout Response => : $response");
      if (response.statusCode == 200) {
        if (employeeLogoutModel.success == true) {
          LoadingDialog.showProgress(context, false);
          SharedPrefs.instance.remove(companyAuthToken);
          SharedPrefs.instance.remove(companyUserId);
          SharedPrefs.instance.remove(companyUserName);
          SharedPrefs.instance.remove(companyUserFirstName);
          SharedPrefs.instance.remove(companyUserLastName);
          SharedPrefs.instance.remove(companyUserEmail);
          SharedPrefs.instance.remove(companyProfilePicture);
          SharedPrefs.instance.remove(isCompanyUserLogin);

          Get.offAllNamed(Routes.selectLoginTypeScreen);
        } else {
          LoadingDialog.showProgress(context, false);
          GetSnackbar(supTitle: employeeLogoutModel.data.toString(), title: "Error");
          SharedPrefs.instance.remove(companyAuthToken);
          SharedPrefs.instance.remove(companyUserId);
          SharedPrefs.instance.remove(companyUserName);
          SharedPrefs.instance.remove(companyUserFirstName);
          SharedPrefs.instance.remove(companyUserLastName);
          SharedPrefs.instance.remove(companyUserEmail);
          SharedPrefs.instance.remove(companyProfilePicture);
          SharedPrefs.instance.remove(isCompanyUserLogin);

          Get.offAllNamed(Routes.selectLoginTypeScreen);
        }
      } else {
        LoadingDialog.showProgress(context, false);
        GetSnackbar(supTitle: employeeLogoutModel.data.toString(), title: "Error");
        SharedPrefs.instance.remove(companyAuthToken);
        SharedPrefs.instance.remove(companyUserId);
        SharedPrefs.instance.remove(companyUserName);
        SharedPrefs.instance.remove(companyUserFirstName);
        SharedPrefs.instance.remove(companyUserLastName);
        SharedPrefs.instance.remove(companyUserEmail);
        SharedPrefs.instance.remove(companyProfilePicture);
        SharedPrefs.instance.remove(isCompanyUserLogin);

        Get.offAllNamed(Routes.selectLoginTypeScreen);
      }
    } catch (e) {
      print("Error : ${e.toString()}");
      LoadingDialog.showProgress(context, false);
      GetSnackbar(supTitle: '', title: "Oops! Something went wrong.");
      SharedPrefs.instance.remove(companyAuthToken);
      SharedPrefs.instance.remove(companyUserId);
      SharedPrefs.instance.remove(companyUserName);
      SharedPrefs.instance.remove(companyUserFirstName);
      SharedPrefs.instance.remove(companyUserLastName);
      SharedPrefs.instance.remove(companyUserEmail);
      SharedPrefs.instance.remove(companyProfilePicture);
      SharedPrefs.instance.remove(isCompanyUserLogin);

      Get.offAllNamed(Routes.selectLoginTypeScreen);
    }
  }

  getAdminProfileDetail() async {
    startLoading();
    try {
      var response =
      await AuthApi.getAdminProfile(authToken: sharePref.getString(companyAuthToken) ?? '', user_id: sharePref.getString(companyUserId) ?? '');
      CompanyProfileModel companyProfileModel = CompanyProfileModel.fromJson(jsonDecode(response.data));
      print("Response Admin Employee Profile => : $response");
      if (response.statusCode == 200) {
        print("Thi is Stuste code:::::${response.statusCode}");

        if (companyProfileModel.success == true) {
          stopLoading();
          profilePic = companyProfileModel.data!.avatar;
          firstName = companyProfileModel.data!.firstname.toString();
          lastName = companyProfileModel.data!.lastname.toString();

          totalEmployee = companyProfileModel.data!.totalEmployees ?? '0';
          totalBranch  = companyProfileModel.data!.totalBranches ?? '0';
          totalFile = companyProfileModel.data!.totalFiles ?? '0';

          sharePref.setString('uploadServerNameCompany', '${companyProfileModel.data!.bucket}');
          sharePref.setString('uploadOrNotCompany', '${companyProfileModel..data!.uploading}');
          sharePref.setString('regionNameCompany', '${companyProfileModel.data!.region}');
          sharePref.setString('bucketNameCompany', '${companyProfileModel.data!.bucketName}');
          sharePref.setString('accessKeyCompany', '${companyProfileModel.data!.accessKey}');
          sharePref.setString('secretKeyCompany', '${companyProfileModel.data!.secretKey}');

          sharePref.setString('docRegionNameCompany', '${companyProfileModel.data!.docRegion}');
          sharePref.setString('docBucketNameCompany', '${companyProfileModel.data!.docBucketName}');
          sharePref.setString('docAccessKeyCompany', '${companyProfileModel.data!.docAccessKey}');
          sharePref.setString('docSecretKeyCompany', '${companyProfileModel.data!.docSecretKey}');

          final _firebaseMassage = FirebaseMessaging.instance;
          await _firebaseMassage.requestPermission();
          final fcmToken = await _firebaseMassage.getToken();

          var uniqueId;
          DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
          if (Platform.isAndroid) {
            AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
            uniqueId = androidInfo.id;
          }else if (Platform.isIOS) {
            final IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
            uniqueId = iosInfo.identifierForVendor!;
          }

          print("uniqueId : $uniqueId");

          var response = await AuthApi.notificationAdmin(authToken: sharePref.getString(companyAuthToken) ?? '', userId: sharePref.getString(companyUserId) ?? '', fcmToken: fcmToken!,uniqueId:uniqueId);

          print("Notification Token Store Admin : $response");

          update();
        }
      } else {
        stopLoading();
        GetSnackbar(supTitle: companyProfileModel.message.toString(), title: "Error");
      }
    } catch (e) {
      print("Error : ${e.toString()}");
      stopLoading();
      GetSnackbar(supTitle: '', title: "Oops! Something went wrong.");
    }
  }
}

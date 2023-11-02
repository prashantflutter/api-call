import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:ehubt_finanace_expence/employee_screen/model/employee_profile/employee_profile.dart';
import 'package:ehubt_finanace_expence/services/attendance_services.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:persistent_bottom_nav_bar_v2/persistent-tab-view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../components/get_snackbar.dart';
import '../../employee_screen/model/auth/employee_logout.dart';
import '../../employee_screen/model/employee_video_player/employee_video_play_model.dart';
import '../../employee_screen/model/notification/notification.dart';
import '../../employee_screen/model/upload/upload_response.dart';
import '../../employee_screen/screens/employee_main_screen/dashboard_screen/dashboard_screen.dart';
import '../../employee_screen/screens/finance_main_screen/finance_main_screen.dart';
import '../../employee_screen/screens/tasky_main_scree/taky_screen.dart';

import '../../routes/routes.dart';
import '../../services/auth_api.dart';
import '../../services/database_service.dart';
import '../../utils/constant/app_assets.dart';
import '../../utils/constant/app_color.dart';
import '../../utils/constant/app_string.dart';
import '../../utils/constant/loading_dialog.dart';
import '../../utils/constant/text_style.dart';
import '../../utils/sharPreferenceUtils.dart';

class EmployeeMainController extends GetxController {
  Rx<PersistentTabController> controller = PersistentTabController(initialIndex: 0).obs;

  int selectedIndex = 0;

  int index = 0;

  ListQueue<int> navigationQueue = ListQueue();

  var sharePref = SharedPrefs.instance;
  bool loading = false;

  var profilePic;
  var firstName = '';
  var lastName = '';
  var designation = '';
  var employeeCompanyName = '';
  var presentDay = '0';
  var lateDay = '0';
  var absentDay = '0';

  List<Detail> thubNailList = [];

  @override
  void onInit() {
    super.onInit();
    navigationQueue.addLast(0);
    getProfile();

    _dataSync();
  }

  var tabs = [
    DashBoardScreen(),
    // FinanceScreen(),
    // FinanceScreen(),
    // FinanceScreen(),
  ].obs;

  void changeTab(int index) {
    controller.value.jumpToTab(index);
    update();
  }

  List<PersistentBottomNavBarItem> navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: SvgPicture.asset(
          employeeIcon,
          height: 24,
          width: 24,
          colorFilter: ColorFilter.mode(kMainColor, BlendMode.srcIn),
        ),
        inactiveIcon: SvgPicture.asset(
          employeeIcon,
          height: 24,
          width: 24,
          colorFilter: ColorFilter.mode(kBlackColor, BlendMode.srcIn),
        ),
        title: ("Employee"),
        textStyle: kTextStyle.copyWith(
          fontSize: 14.0,
          fontWeight: FontWeight.w700,
        ),
        activeColorPrimary: kMainColor,
        inactiveColorPrimary: Get.isDarkMode ? Colors.white : Colors.black,
        inactiveColorSecondary: Get.isDarkMode ? Colors.white : Colors.black,
      ),
      PersistentBottomNavBarItem(
        icon: SvgPicture.asset(
          finance,
          height: 24,
          width: 24,
          colorFilter: ColorFilter.mode(kMainColor, BlendMode.srcIn),
        ),
        inactiveIcon: SvgPicture.asset(
          finance,
          height: 24,
          width: 24,
          colorFilter: ColorFilter.mode(kBlackColor, BlendMode.srcIn),
        ),
        title: ("Finance"),
        textStyle: kTextStyle.copyWith(
          fontSize: 14.0,
          fontWeight: FontWeight.w700,
        ),
        activeColorPrimary: kMainColor,
        inactiveColorPrimary: Get.isDarkMode ? Colors.white : Colors.black,
        inactiveColorSecondary: Get.isDarkMode ? Colors.white : Colors.black,
      ),
      PersistentBottomNavBarItem(
        icon: SvgPicture.asset(
          task,
          height: 24,
          width: 24,
          colorFilter: ColorFilter.mode(kMainColor, BlendMode.srcIn),
        ),
        inactiveIcon: SvgPicture.asset(
          task,
          height: 24,
          width: 24,
          colorFilter: ColorFilter.mode(kBlackColor, BlendMode.srcIn),
        ),
        title: ("Tasky"),
        textStyle: kTextStyle.copyWith(
          fontSize: 14.0,
          fontWeight: FontWeight.w700,
        ),
        activeColorPrimary: kMainColor,
        inactiveColorPrimary: Get.isDarkMode ? Colors.white : Colors.black,
        inactiveColorSecondary: Get.isDarkMode ? Colors.white : Colors.black,
      ),
      PersistentBottomNavBarItem(
        icon: SvgPicture.asset(
          iRotas,
          height: 24,
          width: 24,
          colorFilter: ColorFilter.mode(kMainColor, BlendMode.srcIn),
        ),
        inactiveIcon: SvgPicture.asset(
          iRotas,
          height: 24,
          width: 24,
          colorFilter: ColorFilter.mode(kBlackColor, BlendMode.srcIn),
        ),
        title: ("E-Pos"),
        textStyle: kTextStyle.copyWith(
          fontSize: 14.0,
          fontWeight: FontWeight.w700,
        ),
        activeColorPrimary: kMainColor,
        inactiveColorPrimary: Get.isDarkMode ? Colors.white : Colors.black,
        inactiveColorSecondary: Get.isDarkMode ? Colors.white : Colors.black,
      ),
    ];
  }

  // int selectedIndex = 0;
  List pages = [
    DashBoardScreen(),
    // FinanceScreen(),
    TaskyScreen(),
    // FinanceScreen(),
  ];

  List<BottomNavigationBarItem> items = [
    BottomNavigationBarItem(
      icon: SvgPicture.asset(
        employeeIcon,
        height: 24,
        width: 24,
      ),
      activeIcon: SvgPicture.asset(
        employeeIcon,
        height: 24,
        width: 24,
        colorFilter: ColorFilter.mode(kMainColor, BlendMode.srcIn),
      ),
      label: "Employee",
    ),
    BottomNavigationBarItem(
        icon: SvgPicture.asset(
          finance,
          height: 24,
          width: 24,
        ),
        activeIcon: SvgPicture.asset(
          finance,
          height: 24,
          width: 24,
          colorFilter: ColorFilter.mode(kMainColor, BlendMode.srcIn),
        ),
        label: "Finance"),
    BottomNavigationBarItem(
        icon: SvgPicture.asset(
          task,
          height: 24,
          width: 24,
        ),
        activeIcon: SvgPicture.asset(
          task,
          height: 24,
          width: 24,
          colorFilter: ColorFilter.mode(kMainColor, BlendMode.srcIn),
        ),
        label: "Task"),
    BottomNavigationBarItem(
        icon: SvgPicture.asset(
          iRotas,
          height: 24,
          width: 24,
        ),
        activeIcon: SvgPicture.asset(
          iRotas,
          height: 24,
          width: 24,
          colorFilter: ColorFilter.mode(kMainColor, BlendMode.srcIn),
        ),
        label: "iRotas"),
  ];

  // void selectedTab(int index) {
  //   selectedIndex = index;
  //   update();
  // }

  void startLoading() {
    loading = true;
    update();
  }

  void stopLoading() {
    loading = false;
    update();
  }

  getProfile() async {
    startLoading();
    try {
      var response = await AuthApi.employeeProfile(authToken: sharePref.getString(authToken) ?? '', userId: sharePref.getString(userId) ?? '');
      EmployeeProfile employeeProfile = EmployeeProfile.fromJson(json.decode(response.data));

      print("Response Employee Profile => : $response");

      if (response.statusCode == 200) {
        if (employeeProfile.success == true) {
          stopLoading();
          profilePic = employeeProfile.data!.userImage;
          firstName = employeeProfile.data!.firstName!;
          lastName = employeeProfile.data!.lastName!;
          employeeCompanyName = employeeProfile.data!.companyName!;
          presentDay = employeeProfile.data!.presentDay ?? '0';
          lateDay = employeeProfile.data!.lateDay ?? '0';
          absentDay = employeeProfile.data!.absentDay ?? '0';

          sharePref.setString(userName, '$firstName $lastName');
          sharePref.setString(profilePicture, '${employeeProfile.data!.userImage}');
          sharePref.setString('designation', '${employeeProfile.data!.designationName}');

          sharePref.setString('EmployeeCompanyName', '${employeeProfile.data!.companyName}');

          ///Bucket Detail
          sharePref.setString('uploadServerName', '${employeeProfile.data!.serverName}');
          sharePref.setString('uploadOrNot', '${employeeProfile.data!.uploading}');
          sharePref.setString('regionName', '${employeeProfile.data!.region}');
          sharePref.setString('bucketName', '${employeeProfile.data!.bucketName}');
          sharePref.setString('accessKey', '${employeeProfile.data!.accessKey}');
          sharePref.setString('secretKey', '${employeeProfile.data!.secretKey}');

          ///Bucket Detail For Document

          sharePref.setString('docRegionNameEmployee', '${employeeProfile.data!.docRegion}');
          sharePref.setString('docBucketNameEmployee', '${employeeProfile.data!.docBucketName}');
          sharePref.setString('docAccessKeyEmployee', '${employeeProfile.data!.docAccessKey}');
          sharePref.setString('docSecretKeyEmployee', '${employeeProfile.data!.docSecretKey}');

          ///Sales and Expense Check Enable Or Not
          sharePref.setString('isExpenseAdd', '${employeeProfile.data!.expense ?? '0'}');
          sharePref.setString('isSalesAdd', '${employeeProfile.data!.sales ?? '0'}');

          sharePref.setString('EmployeeChatUrl', '${employeeProfile.data!.chatUrl}');

          update();

          final _firebaseMassage = FirebaseMessaging.instance;
          await _firebaseMassage.requestPermission();
          final fcmToken = await _firebaseMassage.getToken();

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
          var response = await AuthApi.notification(
              authToken: sharePref.getString(authToken) ?? '', userId: sharePref.getString(userId) ?? '', fcmToken: fcmToken!, uniqueId: uniqueId);
          print("Notification Token Store : $response");
        } else {
          stopLoading();
          GetSnackbar(supTitle: employeeProfile.message.toString(), title: "Error");
        }
      } else {
        stopLoading();
        GetSnackbar(supTitle: employeeProfile.message.toString(), title: "Error");
      }
    } catch (e) {
      stopLoading();
      GetSnackbar(supTitle: '', title: "Oops! Something went wrong.");
    }
  }

  getProfileForValidation(BuildContext context, String validationType) async {
    LoadingDialog.showProgress(context, true);
    try {
      var response = await AuthApi.employeeProfile(authToken: sharePref.getString(authToken) ?? '', userId: sharePref.getString(userId) ?? '');
      EmployeeProfile employeeProfile = EmployeeProfile.fromJson(json.decode(response.data));

      print("Response Employee Profile => : $response");
      if (response.statusCode == 200) {
        if (employeeProfile.success == true) {
          LoadingDialog.showProgress(context, false);

          if (validationType == 'E-Rota') {
            if (employeeProfile.data!.iRota == '1') {
              Get.toNamed(Routes.eRotasScreen);
            } else {
              GetSnackbar(supTitle: 'Features is not available for you, Please contact to HR Person.', title: "Warning");
            }
          } else if (validationType == 'Your Work Availability') {
            if (employeeProfile.data!.workAvailability == '1') {
              Get.toNamed(Routes.yorkWorkAvailabilityScreen);
            } else {
              GetSnackbar(supTitle: 'Features is not available for you, Please contact to HR Person.', title: "Warning");
            }
          } else if (validationType == 'Request shift swap') {
            if (employeeProfile.data!.requestShiftSwap == '1') {
              Get.toNamed(Routes.requestShiftSwap);
            } else {
              GetSnackbar(supTitle: 'Features is not available for you, Please contact to HR Person.', title: "Warning");
            }
          } else if (validationType == 'Request Holidays') {
            if (employeeProfile.data!.requestHolidays == '1') {
              Get.toNamed(Routes.leaveManagementScreen);
            } else {
              GetSnackbar(supTitle: 'Features is not available for you, Please contact to HR Person.', title: "Warning");
            }
          }
        } else {
          LoadingDialog.showProgress(context, false);
          GetSnackbar(supTitle: employeeProfile.message.toString(), title: "Error");
        }
      } else {
        LoadingDialog.showProgress(context, false);
        GetSnackbar(supTitle: employeeProfile.message.toString(), title: "Error");
      }
    } catch (e) {
      LoadingDialog.showProgress(context, false);
      GetSnackbar(supTitle: '', title: "Oops! Something went wrong.");
    }
  }

  greeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    }
    if (hour < 17) {
      return 'Good Afternoon';
    }
    return 'Good Evening';
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
      var response = await AuthApi.logoutEmployee(
          authToken: sharePref.getString(authToken) ?? '', userId: sharePref.getString(userId) ?? '', uniqueId: uniqueId);
      EmployeeLogoutModel employeeLogoutModel = EmployeeLogoutModel.fromJson(json.decode(response.data));
      print("Employee Logout Response => : $response");
      if (response.statusCode == 200) {
        if (employeeLogoutModel.success == true) {
          LoadingDialog.showProgress(context, false);
          SharedPrefs.instance.remove(authToken);
          SharedPrefs.instance.remove(isUserLogin);
          SharedPrefs.instance.remove(userId);
          SharedPrefs.instance.remove(loginType);
          SharedPrefs.instance.remove(jobType);
          SharedPrefs.instance.remove(userName);
          SharedPrefs.instance.remove(profilePicture);
          SharedPrefs.instance.remove(branchId);
          Get.offAllNamed(Routes.loginScreen);
        } else {
          LoadingDialog.showProgress(context, false);
          GetSnackbar(supTitle: employeeLogoutModel.data.toString(), title: "Error");
          SharedPrefs.instance.remove(authToken);
          SharedPrefs.instance.remove(isUserLogin);
          SharedPrefs.instance.remove(userId);
          SharedPrefs.instance.remove(loginType);
          SharedPrefs.instance.remove(jobType);
          SharedPrefs.instance.remove(userName);
          SharedPrefs.instance.remove(profilePicture);
          SharedPrefs.instance.remove(branchId);
          Get.offAllNamed(Routes.loginScreen);
        }
      } else {
        LoadingDialog.showProgress(context, false);
        GetSnackbar(supTitle: employeeLogoutModel.data.toString(), title: "Error");
        SharedPrefs.instance.remove(authToken);
        SharedPrefs.instance.remove(isUserLogin);
        SharedPrefs.instance.remove(userId);
        SharedPrefs.instance.remove(loginType);
        SharedPrefs.instance.remove(jobType);
        SharedPrefs.instance.remove(userName);
        SharedPrefs.instance.remove(profilePicture);
        SharedPrefs.instance.remove(branchId);
        Get.offAllNamed(Routes.loginScreen);
      }
    } catch (e) {
      print("Error : ${e.toString()}");
      LoadingDialog.showProgress(context, false);
      GetSnackbar(supTitle: '', title: "Oops! Something went wrong.");
      SharedPrefs.instance.remove(authToken);
      SharedPrefs.instance.remove(isUserLogin);
      SharedPrefs.instance.remove(userId);
      SharedPrefs.instance.remove(loginType);
      SharedPrefs.instance.remove(jobType);
      SharedPrefs.instance.remove(userName);
      SharedPrefs.instance.remove(profilePicture);
      SharedPrefs.instance.remove(branchId);
      Get.offAllNamed(Routes.loginScreen);
    }
  }

  logoutFromCompany(BuildContext context) async {
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
      var response = await AuthApi.logoutEmployee(
          authToken: sharePref.getString(authToken) ?? '', userId: sharePref.getString(userId) ?? '', uniqueId: uniqueId);
      EmployeeLogoutModel employeeLogoutModel = EmployeeLogoutModel.fromJson(json.decode(response.data));
      print("Employee Logout Response => : $response");
      if (response.statusCode == 200) {
        if (employeeLogoutModel.success == true) {
          LoadingDialog.showProgress(context, false);
          SharedPrefs.instance.remove(authToken);
          SharedPrefs.instance.remove(isUserLogin);
          SharedPrefs.instance.remove(companyKey);
          SharedPrefs.instance.remove(userId);
          SharedPrefs.instance.remove(loginType);
          SharedPrefs.instance.remove(jobType);
          SharedPrefs.instance.remove(userName);
          SharedPrefs.instance.remove(profilePicture);
          SharedPrefs.instance.remove(branchId);
          SharedPrefs.instance.remove(employeeUserName);
          SharedPrefs.instance.remove(employeePassword);

          Get.offAllNamed(Routes.selectLoginTypeScreen);
        } else {
          LoadingDialog.showProgress(context, false);
          GetSnackbar(supTitle: employeeLogoutModel.data.toString(), title: "Error");
          SharedPrefs.instance.remove(authToken);
          SharedPrefs.instance.remove(isUserLogin);
          SharedPrefs.instance.remove(companyKey);
          SharedPrefs.instance.remove(userId);
          SharedPrefs.instance.remove(loginType);
          SharedPrefs.instance.remove(jobType);
          SharedPrefs.instance.remove(userName);
          SharedPrefs.instance.remove(profilePicture);
          SharedPrefs.instance.remove(branchId);
          SharedPrefs.instance.remove(employeeUserName);
          SharedPrefs.instance.remove(employeePassword);

          Get.offAllNamed(Routes.selectLoginTypeScreen);
        }
      } else {
        LoadingDialog.showProgress(context, false);
        GetSnackbar(supTitle: employeeLogoutModel.data.toString(), title: "Error");
        SharedPrefs.instance.remove(authToken);
        SharedPrefs.instance.remove(isUserLogin);
        SharedPrefs.instance.remove(companyKey);
        SharedPrefs.instance.remove(userId);
        SharedPrefs.instance.remove(loginType);
        SharedPrefs.instance.remove(jobType);
        SharedPrefs.instance.remove(userName);
        SharedPrefs.instance.remove(profilePicture);
        SharedPrefs.instance.remove(branchId);
        SharedPrefs.instance.remove(employeeUserName);
        SharedPrefs.instance.remove(employeePassword);

        Get.offAllNamed(Routes.selectLoginTypeScreen);
      }
    } catch (e) {
      print("Error : ${e.toString()}");
      LoadingDialog.showProgress(context, false);
      GetSnackbar(supTitle: '', title: "Oops! Something went wrong.");
      SharedPrefs.instance.remove(authToken);
      SharedPrefs.instance.remove(isUserLogin);
      SharedPrefs.instance.remove(companyKey);
      SharedPrefs.instance.remove(userId);
      SharedPrefs.instance.remove(loginType);
      SharedPrefs.instance.remove(jobType);
      SharedPrefs.instance.remove(userName);
      SharedPrefs.instance.remove(profilePicture);
      SharedPrefs.instance.remove(branchId);
      SharedPrefs.instance.remove(employeeUserName);
      SharedPrefs.instance.remove(employeePassword);

      Get.offAllNamed(Routes.selectLoginTypeScreen);
    }
  }

  _dataSync() {
    var oneSec = Duration(seconds: 30);

    Timer scheduleTimer = Timer.periodic(oneSec, (timer1) async {
      var authToken = sharePref.getString('authToken') ?? '';
      var userId = sharePref.getString('userId') ?? '';
      final DatabaseService _databaseService = DatabaseService();

      final db = await _databaseService.database;
      var _availableEmp = await _databaseService.checkEmp(userId);

      try {
        var attendanceData =
            json.encode(await db.rawQuery("SELECT * FROM Attendance_Employee WHERE uploadStatus = '0' and jobType = '${_availableEmp?.jobType}'"));

        print("Clock In Out Employee : $attendanceData");

        var response = await AttendanceApi.uploadAttendanceList(authToken: authToken, data: attendanceData);

        print("response attendanceDta => " + response.toString());

        Upload upload = Upload.fromJson(json.decode(response.data));

        if (response.statusCode == 200) {
          if (upload?.success == true) {
            await db.rawUpdate('UPDATE Attendance_Employee SET uploadStatus = ? WHERE uploadStatus = ?', ["1", "0"]);
          } else {}
        } else {}
      } catch (e) {
        print("Error : ${e.toString()}");
      }

      try {
        var breakData =
            json.encode(await db.rawQuery("SELECT * FROM Attendance_Break WHERE uploadStatus = '0' and jobType = '${_availableEmp?.jobType}'"));

        print("Break In Out Employee : $breakData");

        var response = await AttendanceApi.uploadBreakList(authToken: authToken, data: breakData);

        print("response attendanceDta => " + response.toString());

        final value = json.decode(response.data);

        Upload uploadBreak = Upload.fromJson(value);

        if (response.statusCode == 200) {
          if (uploadBreak?.success == true) {
            await db.rawUpdate('UPDATE Attendance_Break SET uploadStatus = ? WHERE uploadStatus = ?', ["1", "0"]);
          } else {}
        } else {}
      } catch (e) {
        print("Error : ${e.toString()}");
      }
    });
  }

  updateBottomMenu(int indexBottom) {
    selectedIndex = indexBottom;
    update();
  }

  updateBackTab(int indexTab) {
    navigationQueue.removeWhere((element) => element == indexTab);

    navigationQueue.addLast(indexTab);

    print("Selected Index : ${navigationQueue}");

    update();
  }

  onWillPop() async {
    exit(0);
  }
}

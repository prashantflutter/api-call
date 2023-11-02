import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../services/database_service.dart';
import '../../utils/constant/app_string.dart';
import '../../utils/sharPreferenceUtils.dart';

class ClockInOutController extends GetxController {
  bool loadingClockInOut = false;
  var empLastStatus = "Clock In";
  var sharePref = SharedPrefs.instance;
  var empName;
  var userId;
  var tabletUserId;

  DatabaseService databaseService = DatabaseService();
  bool isStartBreakClockOutVisible = false;
  @override
  onInit() async {


    empName = sharePref.getString('userName') ?? '';
    userId = sharePref.getString('userId') ?? '';
    tabletUserId = sharePref.getString(tabletId).toString() ?? '';

    update();
    print("UserId : ${userId}");
    var _availableEmp = await databaseService.checkEmp(userId);

    var _checkAttendance = await databaseService.checkAttendanceEmp(userId, DateFormat('dd-MM-yyyy').format(DateTime.now()).toString(), _availableEmp!.jobType);

    print("Check Employee Attendance : $_checkAttendance");

    if (_checkAttendance != null) {
      var status = _checkAttendance.Last_Status.toString();

      if (_availableEmp?.jobType == "1") {
        if (status == "") {
          empLastStatus = "Job Started";
        } else if (status == "clock_in") {
          empLastStatus = "Job Ended";
        } else if (status == "clock_out") {
          empLastStatus = "Job Started";
        }
      } else {
        if (status == "") {
          empLastStatus = "Clock In";
        } else if (status == "clock_in") {
          isStartBreakClockOutVisible = true;
          empLastStatus = "Start Break";
        } else if (status == "break_in") {
          empLastStatus = "Finish Break";
        } else if (status == "break_out") {
          isStartBreakClockOutVisible = true;
          empLastStatus = "Start Break";
        } else if (status == "clock_out") {
          empLastStatus = "Clock In";
        }
      }
    } else {
      if (_availableEmp?.jobType == "1") {
        empLastStatus = "Job Started";
      } else {
        empLastStatus = "Clock In";
      }
    }

    update();

    super.onInit();
  }

  void startLoadingClockInOut() {
    loadingClockInOut = true;
    update();
  }

  void stopLoadingClockInOut() {
    loadingClockInOut = false;
    update();
  }

}

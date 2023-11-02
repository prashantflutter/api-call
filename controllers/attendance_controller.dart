import 'dart:convert';

import 'package:ehubt_finanace_expence/utils/constant/app_color.dart';
import 'package:ehubt_finanace_expence/utils/constant/app_string.dart';
import 'package:flutter/material.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_calendar_carousel/flutter_calendar_carousel.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../components/get_snackbar.dart';
import '../../employee_screen/model/check_attendance.dart';
import '../../model/attendance.dart';
import '../../model/local_database_model/attendance_break.dart';
import '../../model/local_database_model/attendance_employee.dart';
import '../../model/local_database_model/employee.dart';
import '../../services/attendance_services.dart';
import '../../services/database_service.dart';
import '../../utils/constant/text_style.dart';
import '../../utils/sharPreferenceUtils.dart';

class AttendanceController extends GetxController {
  var todayDate = DateFormat('dd-MM-yyyy').format(DateTime.now());

  final DateFormat formatter = DateFormat('yyyy-MM-dd');
  EventList<Event> _markedDateMap = new EventList<Event>(
    events: {},
  );
  var sharePref = SharedPrefs.instance;
  DateTime _currentDate2 = DateTime.now();
  DateTime _targetDateTime = DateTime.now();

  var progress = 0.0;
  var startTime;
  var endTime;
  var totalHour;

  bool loading = false;
  bool loadingAttendance = false;
  var employeeName = '';
  var tabletUserId;

  var allowSelfAttendance = '0';
  var asPerJobSalary = '0';

  final DatabaseService _databaseService = DatabaseService();

  List<EmpCodeAttendanceData> _empCodeAttendanceList = [];
  List<EmpCodeBreakData> _empCodeBreakList = [];

  int _clockInOutCounter = 0;
  int _breakInOutCounter = 0;

  @override
  void onInit() {
    employeeName = sharePref.getString(userName) ?? '';
    tabletUserId = sharePref.getString(tabletId).toString() ?? '';
    update();
    getAttendance();
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

  void startLoadingAttendance() {
    loadingAttendance = true;
    update();
  }

  void stopLoadingAttendance() {
    loadingAttendance = false;
    update();
  }

  getAttendance() async {
    final db = await _databaseService.database;
    startLoading();
    try {
      var response = await AttendanceApi.getAttendance(authToken: sharePref.getString(authToken) ?? '', userId: sharePref.getString('userId') ?? '');
      print("Response Attendance : ${response.toString()}");
      Attendance attendance = Attendance.fromJson(json.decode(response.data));
      if (response.statusCode == 200) {
        if (attendance?.success == true) {
          stopLoading();
          allowSelfAttendance = attendance.allowSelfAttendance != null ? attendance.allowSelfAttendance! : '0';
          asPerJobSalary = attendance.asPerJobSalary != null ? attendance.asPerJobSalary! : '0';
          _markedDateMap.clear();
          for (int i = 0; i < attendance!.data!.length; i++) {
            final tomorrow = formatter.parse((DateTime.now().add(Duration(days: 1))).toString());
            print("Date Time1 : ${formatter.parse(attendance!.data![i].date.toString())}");
            if (formatter.parse(attendance!.data![i].date.toString()) == tomorrow) {
              break;
            } else {
              _markedDateMap.add(
                formatter.parse(attendance!.data![i].date.toString()),
                new Event(
                  date: formatter.parse(attendance!.data![i].date.toString()),
                  title: 'Event',
                  icon: attendance!.data![i].status == 1
                      ? _presentIcon(formatter.parse(attendance!.data![i].date.toString()).day.toString())
                      : attendance!.data![i].status == 2
                          ? _absentIcon(formatter.parse(attendance!.data![i].date.toString()).day.toString())
                          : attendance!.data![i].status == 3
                              ? _holidayIcon(formatter.parse(attendance!.data![i].date.toString()).day.toString())
                              : attendance!.data![i].status == 4
                                  ? _emptyIcon(formatter.parse(attendance!.data![i].date.toString()).day.toString())
                                  : _absentIcon(formatter.parse(attendance!.data![i].date.toString()).day.toString()),
                ),
              );
            }
          }

          var _checkEmp = await _databaseService.checkEmp(sharePref.getString('userId') ?? '');
          if (_checkEmp == null) {
          } else {
            await db.rawUpdate(
                'UPDATE employee SET jobType = ? WHERE id = ?', [attendance.asPerJobSalary != null ? attendance.asPerJobSalary! : '0', _checkEmp.id]);
          }
          update();

          checkAttendance();
        }
      } else {
        stopLoading();
        GetSnackbar(supTitle: attendance.message.toString(), title: "Error");
      }
    } catch (error) {
      stopLoading();
      GetSnackbar(supTitle: '', title: "Oops! Something went wrong.");
    }
  }

  Widget _holidayIcon(String day) => CircleAvatar(
        backgroundColor: kMainColor,
        child: Text(
          day,
          style: kTextStyle.copyWith(
            color: kWhiteColor,
          ),
        ),
      );

  Widget _presentIcon(String day) => CircleAvatar(
        backgroundColor: Colors.green,
        child: Text(
          day,
          style: kTextStyle.copyWith(
            color: kWhiteColor,
          ),
        ),
      );

  Widget _absentIcon(String day) => CircleAvatar(
        backgroundColor: Colors.red,
        child: Text(
          day,
          style: kTextStyle.copyWith(
            color: kWhiteColor,
          ),
        ),
      );

  Widget _emptyIcon(String day) => CircleAvatar(
        backgroundColor: Colors.transparent,
      );

  attendanceDialog(BuildContext context) {
    Dialog alert = Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 30),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(color: kWhiteColor, borderRadius: BorderRadius.circular(10.0)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GetBuilder<AttendanceController>(builder: (_) {
              return CalendarCarousel<Event>(
                todayBorderColor: Colors.transparent,
                onDayPressed: (date, events) {
                  _currentDate2 = date;
                  todayDate = DateFormat('dd-MM-yyyy').format(date);
                  events.forEach((event) => print(event.title));
                  update();
                },
                weekDayFormat: WeekdayFormat.narrow,
                daysHaveCircularBorder: true,
                showOnlyCurrentMonthDate: false,
                weekendTextStyle: kTextStyle.copyWith(
                  color: kSilverColor,
                ),
                weekdayTextStyle: kTextStyle.copyWith(fontSize: 14, color: kBlackColor),
                headerTextStyle: kTextStyle.copyWith(fontSize: 16, color: kBlackColor),
                thisMonthDayBorderColor: Colors.transparent,
                weekFormat: false,
                markedDatesMap: _markedDateMap,
                height: 420.0,
                selectedDateTime: _currentDate2,
                targetDateTime: _targetDateTime,
                selectedDayBorderColor: kMainColor,
                selectedDayButtonColor: Colors.transparent,
                customGridViewPhysics: NeverScrollableScrollPhysics(),
                // markedDateCustomShapeBorder: CircleBorder(side: BorderSide(color: Colors.yellow)),
                markedDateCustomTextStyle: kTextStyle.copyWith(
                  fontSize: 18,
                  color: kBlackColor,
                ),
                showHeader: true,
                todayTextStyle: kTextStyle.copyWith(
                  color: kBlackColor,
                ),
                markedDateShowIcon: true,
                markedDateIconMaxShown: 2,
                markedDateIconBuilder: (event) {
                  return event.icon;
                },
                markedDateMoreShowTotal: true,
                todayButtonColor: Colors.transparent,
                selectedDayTextStyle: kTextStyle.copyWith(
                  color: kBlackColor,
                ),
                prevDaysTextStyle: kTextStyle.copyWith(
                  fontSize: 16,
                  color: kWhiteColor,
                ),
                inactiveDaysTextStyle: kTextStyle.copyWith(
                  color: kGreyTextColor,
                  fontSize: 16,
                ),
                onCalendarChanged: (DateTime date) {
                  _targetDateTime = date;
                  update();
                },
              );
            }),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        height: 10,
                        width: 10,
                        decoration: BoxDecoration(color: kGreenColor, shape: BoxShape.circle),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        "Present",
                        style: kTextStyle.copyWith(fontSize: 12, color: kTitleColor),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Row(
                    children: [
                      Container(
                        height: 10,
                        width: 10,
                        decoration: BoxDecoration(color: kRedColor, shape: BoxShape.circle),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        "Absent",
                        style: kTextStyle.copyWith(fontSize: 12, color: kTitleColor),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Row(
                    children: [
                      Container(
                        height: 10,
                        width: 10,
                        decoration: BoxDecoration(color: kMainColor, shape: BoxShape.circle),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        "Holiday",
                        style: kTextStyle.copyWith(fontSize: 12, color: kTitleColor),
                      ),
                    ],
                  )
                ],
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            Container(
              width: double.infinity,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Cancel'.toUpperCase(),
                      style: kTextStyle.copyWith(color: kMainColor, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  ),
                  GetBuilder<AttendanceController>(builder: (_) {
                    return TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        checkAttendance();
                      },
                      child: Text(
                        'Ok'.toUpperCase(),
                        style: kTextStyle.copyWith(color: kMainColor, fontSize: 12, fontWeight: FontWeight.w700),
                      ),
                    );
                  })
                ],
              ),
            ),
            SizedBox(
              height: 10,
            )
          ],
        ),
      ),
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  checkAttendance() async {
    startLoadingAttendance();
    print("UserId 12 : ${sharePref.getString(userId) ?? ''}");
    try {
      var response = await AttendanceApi.checkAttendance(
          authToken: sharePref.getString(authToken) ?? '', userId: sharePref.getString('userId') ?? '', date: todayDate);
      CheckAttendance checkAttendance = CheckAttendance.fromJson(json.decode(response.data));

      print("Response12 Employee Check Attendance => : $response");

      if (response.statusCode == 200) {
        stopLoadingAttendance();

        if (checkAttendance.success == true) {
          startTime = checkAttendance.data!.startTime;
          endTime = checkAttendance.data!.endTime!;
          totalHour = checkAttendance.data!.totalTime!;
          final db = await _databaseService.database;
          _empCodeAttendanceList.clear();
          _empCodeBreakList.clear();

          if (checkAttendance!.data!.attendanceData != null) {
            _empCodeAttendanceList.addAll((checkAttendance!.data!.attendanceData)!.map((x) => EmpCodeAttendanceData.fromJson(x.toJson())).toList());
          }

          if (checkAttendance!.data!.breakData != null) {
            _empCodeBreakList.addAll((checkAttendance!.data!.breakData)!.map((x) => EmpCodeBreakData.fromJson(x.toJson())).toList());
          }

          print("_empCodeAttendanceList Length : ${_empCodeAttendanceList.length}");

          print("_empCodeBreakList.length  : ${_empCodeBreakList.length}");

          var _checkEmp = await _databaseService.checkEmp(sharePref.getString('userId') ?? '');
          if (_checkEmp == null) {
            return;
          }

          if (_empCodeAttendanceList.length > 0) {
            var _empCheckAttendance =
                await _databaseService.checkAttendanceEmp1(_checkEmp.empCode, DateFormat('dd-MM-yyyy').format(DateTime.now()).toString());
            if (_empCheckAttendance != null) {
              _empCodeAttendanceList.forEach((element) async {
                if (element.tabletId == userId) {
                  _clockInOutCounter = int.parse(element.clockInOutCounter!);
                  _breakInOutCounter = int.parse(element.breakInOutCounter!);
                  update();
                  print("Employee ClockInOutCounter : ${_empCheckAttendance.Clock_In_Out_Counter}");
                  print("Employee BreakInOutCounter : ${_empCheckAttendance!.Break_In_Out_Counter}");
                  print("Employee BreakInOutCounter1 : ${element.clockInOutCounter}");
                  if (int.parse(_empCheckAttendance.Clock_In_Out_Counter) > int.parse(element.clockInOutCounter!)) {
                    print("Employee Not Update");
                    return;
                  } else {
                    print("Employee Update");
                    print("Employee Update12");
                    await db.rawUpdate(
                        'UPDATE Attendance_Employee SET empCode = ?,empName = ?,attendanceDate = ?,Cl1 = ?,Co1 = ?,Cl2 = ?,Co2 = ?,Cl3 = ?,Co3 = ?,Cl4 = ?,Co4 = ?,Cl5 = ?,Co5 = ?,Cl6 = ?,Co6 = ?,Cl7 = ?,Co7 = ?,Cl8 = ?,Co8 = ?,Cl9 = ?,Co9 = ?,Cl10 = ?,Co10 = ?,Cl11 = ?,Co11 = ?,Cl12 = ?,Co12 = ?,Cl13 = ?,Co13 = ?,Cl14 = ?,Co14 = ?,Cl15 = ?,Co15 = ?,Cl16 = ?,Co16 = ?,Cl17 = ?,Co17 = ?,Cl18 = ?,Co18 = ?,Cl19 = ?,Co19 = ?,Cl20 = ?,Co20 = ?,Clock_In_Out_Counter = ?,Break_In_Out_Counter = ?,image1 = ?,image2 = ?,image3 = ?,image4 = ?,image5 = ?,image6 = ?,image7 = ?,image8 = ?,image9 = ?,image10 = ?,image11 = ?,image12 = ?,image13 = ?,image14 = ?,image15 = ?,image16 = ?,image17 = ?,image18 = ?,image19 = ?,image20 = ?,imageOut1 = ?,imageOut2 = ?,imageOut3 = ?,imageOut4 = ?,imageOut5 = ?,imageOut6 = ?,imageOut7 = ?,imageOut8 = ?,imageOut9 = ?,imageOut10 = ?,imageOut11 = ?,imageOut12 = ?,imageOut13 = ?,imageOut14 = ?,imageOut15 = ?,imageOut16 = ?,imageOut17 = ?,imageOut18 = ?,imageOut19 = ?,imageOut20 = ?,syncStatusIn1 = ?,syncStatusIn2 = ?,syncStatusIn3 = ?,syncStatusIn4 = ?,syncStatusIn5 = ?,syncStatusIn6 = ?,syncStatusIn7 = ?,syncStatusIn8 = ?,syncStatusIn9 = ?,syncStatusIn10 = ?,syncStatusIn11 = ?,syncStatusIn12 = ?,syncStatusIn13 = ?,syncStatusIn14 = ?,syncStatusIn15 = ?,syncStatusIn16 = ?,syncStatusIn17 = ?,syncStatusIn18 = ?,syncStatusIn19 = ?,syncStatusIn20 = ?,syncStatusOut1 = ?,syncStatusOut2 = ?,syncStatusOut3 = ?,syncStatusOut4 = ?,syncStatusOut5 = ?,syncStatusOut6 = ?,syncStatusOut7 = ?,syncStatusOut8 = ?,syncStatusOut9 = ?,syncStatusOut10 = ?,syncStatusOut11 = ?,syncStatusOut12 = ?,syncStatusOut13 = ?,syncStatusOut14 = ?,syncStatusOut15 = ?,syncStatusOut16 = ?,syncStatusOut17 = ?,syncStatusOut18 = ?,syncStatusOut19 = ?,syncStatusOut20 = ?,Last_Status = ?,lastBreakTableId = ?,uploadStatus = ?,tabletUserId = ?,createAt = ? WHERE id = ?',
                        [
                          element.employeeId,
                          element.name,
                          element.date,
                          element.clockIn,
                          element.clockOut,
                          element.clockIn2,
                          element.clockOut2,
                          element.clockIn3,
                          element.clockOut3,
                          element.clockIn4,
                          element.clockOut4,
                          element.clockIn5,
                          element.clockOut5,
                          element.clockIn6,
                          element.clockOut6,
                          element.clockIn7,
                          element.clockOut7,
                          element.clockIn8,
                          element.clockOut8,
                          element.clockIn9,
                          element.clockOut9,
                          element.clockIn10,
                          element.clockOut10,
                          element.clockIn11,
                          element.clockOut11,
                          element.clockIn12,
                          element.clockOut12,
                          element.clockIn13,
                          element.clockOut13,
                          element.clockIn14,
                          element.clockOut14,
                          element.clockIn15,
                          element.clockOut15,
                          element.clockIn16,
                          element.clockOut16,
                          element.clockIn17,
                          element.clockOut17,
                          element.clockIn18,
                          element.clockOut18,
                          element.clockIn19,
                          element.clockOut19,
                          element.clockIn20,
                          element.clockOut20,
                          element.clockInOutCounter,
                          element.breakInOutCounter,
                          element.image1 != null ? element.image1! : '',
                          element.image2 != null ? element.image2! : '',
                          element.image3 != null ? element.image3! : '',
                          element.image4 != null ? element.image4! : '',
                          element.image5 != null ? element.image5! : '',
                          element.image6 != null ? element.image6! : '',
                          element.image7 != null ? element.image7! : '',
                          element.image8 != null ? element.image8! : '',
                          element.image9 != null ? element.image9! : '',
                          element.image10 != null ? element.image10! : '',
                          element.image11 != null ? element.image11! : '',
                          element.image12 != null ? element.image12! : '',
                          element.image13 != null ? element.image13! : '',
                          element.image14 != null ? element.image14! : '',
                          element.image15 != null ? element.image15! : '',
                          element.image16 != null ? element.image16! : '',
                          element.image17 != null ? element.image17! : '',
                          element.image18 != null ? element.image18! : '',
                          element.image19 != null ? element.image19! : '',
                          element.image20 != null ? element.image20! : '',
                          element.imageOut1 != null ? element.imageOut1! : '',
                          element.imageOut2 != null ? element.imageOut2! : '',
                          element.imageOut3 != null ? element.imageOut3! : '',
                          element.imageOut4 != null ? element.imageOut4! : '',
                          element.imageOut5 != null ? element.imageOut5! : '',
                          element.imageOut6 != null ? element.imageOut6! : '',
                          element.imageOut7 != null ? element.imageOut7! : '',
                          element.imageOut8 != null ? element.imageOut8! : '',
                          element.imageOut9 != null ? element.imageOut9! : '',
                          element.imageOut10 != null ? element.imageOut10! : '',
                          element.imageOut11 != null ? element.imageOut11! : '',
                          element.imageOut12 != null ? element.imageOut12! : '',
                          element.imageOut13 != null ? element.imageOut13! : '',
                          element.imageOut14 != null ? element.imageOut14! : '',
                          element.imageOut15 != null ? element.imageOut15! : '',
                          element.imageOut16 != null ? element.imageOut16! : '',
                          element.imageOut17 != null ? element.imageOut17! : '',
                          element.imageOut18 != null ? element.imageOut18! : '',
                          element.imageOut19 != null ? element.imageOut19! : '',
                          element.imageOut20 != null ? element.imageOut20! : '',
                          element.clockIn != '00:00:00' ? '1' : '0',
                          element.clockIn2 != '00:00:00' ? '1' : '0',
                          element.clockIn3 != '00:00:00' ? '1' : '0',
                          element.clockIn4 != '00:00:00' ? '1' : '0',
                          element.clockIn5 != '00:00:00' ? '1' : '0',
                          element.clockIn6 != '00:00:00' ? '1' : '0',
                          element.clockIn7 != '00:00:00' ? '1' : '0',
                          element.clockIn8 != '00:00:00' ? '1' : '0',
                          element.clockIn9 != '00:00:00' ? '1' : '0',
                          element.clockIn10 != '00:00:00' ? '1' : '0',
                          element.clockIn11 != '00:00:00' ? '1' : '0',
                          element.clockIn12 != '00:00:00' ? '1' : '0',
                          element.clockIn13 != '00:00:00' ? '1' : '0',
                          element.clockIn14 != '00:00:00' ? '1' : '0',
                          element.clockIn15 != '00:00:00' ? '1' : '0',
                          element.clockIn16 != '00:00:00' ? '1' : '0',
                          element.clockIn17 != '00:00:00' ? '1' : '0',
                          element.clockIn18 != '00:00:00' ? '1' : '0',
                          element.clockIn19 != '00:00:00' ? '1' : '0',
                          element.clockIn20 != '00:00:00' ? '1' : '0',
                          element.clockOut != '00:00:00' ? '1' : '0',
                          element.clockOut2 != '00:00:00' ? '1' : '0',
                          element.clockOut3 != '00:00:00' ? '1' : '0',
                          element.clockOut4 != '00:00:00' ? '1' : '0',
                          element.clockOut5 != '00:00:00' ? '1' : '0',
                          element.clockOut6 != '00:00:00' ? '1' : '0',
                          element.clockOut7 != '00:00:00' ? '1' : '0',
                          element.clockOut8 != '00:00:00' ? '1' : '0',
                          element.clockOut9 != '00:00:00' ? '1' : '0',
                          element.clockOut10 != '00:00:00' ? '1' : '0',
                          element.clockOut11 != '00:00:00' ? '1' : '0',
                          element.clockOut12 != '00:00:00' ? '1' : '0',
                          element.clockOut13 != '00:00:00' ? '1' : '0',
                          element.clockOut14 != '00:00:00' ? '1' : '0',
                          element.clockOut15 != '00:00:00' ? '1' : '0',
                          element.clockOut16 != '00:00:00' ? '1' : '0',
                          element.clockOut17 != '00:00:00' ? '1' : '0',
                          element.clockOut18 != '00:00:00' ? '1' : '0',
                          element.clockOut19 != '00:00:00' ? '1' : '0',
                          element.clockOut20 != '00:00:00' ? '1' : '0',
                          element.lastStatus!,
                          element.lastBreakTableId != null ? element.lastBreakTableId! : '',
                          '1',
                          element.tabletId != null ? element.tabletId! : '',
                          DateFormat('yyyy-MM-dd').format(DateTime.now()).toString(),
                          _empCheckAttendance.id
                        ]);
                  }
                }
              });
            } else {
              _empCodeAttendanceList.forEach((element) async {
                if (element.employeeId == _checkEmp.empCode) {
                  await _databaseService.insertAttendance(
                    AttendanceEmployee(
                      userId: _checkEmp.userId,
                      empCode: element.employeeId!,
                      empName: element.name!,
                      attendanceDate: element.date!,
                      Cl1: element.clockIn!,
                      Co1: element.clockOut!,
                      Cl2: element.clockIn2!,
                      Co2: element.clockOut2!,
                      Cl3: element.clockIn3!,
                      Co3: element.clockOut3!,
                      Cl4: element.clockIn4!,
                      Co4: element.clockOut4!,
                      Cl5: element.clockIn5!,
                      Co5: element.clockOut5!,
                      Cl6: element.clockIn6!,
                      Co6: element.clockOut6!,
                      Cl7: element.clockIn7!,
                      Co7: element.clockOut7!,
                      Cl8: element.clockIn8!,
                      Co8: element.clockOut8!,
                      Cl9: element.clockIn9!,
                      Co9: element.clockOut9!,
                      Cl10: element.clockIn10!,
                      Co10: element.clockOut10!,
                      Cl11: element.clockIn11!,
                      Co11: element.clockOut11!,
                      Cl12: element.clockIn12!,
                      Co12: element.clockOut12!,
                      Cl13: element.clockIn13!,
                      Co13: element.clockOut13!,
                      Cl14: element.clockIn14!,
                      Co14: element.clockOut14!,
                      Cl15: element.clockIn15!,
                      Co15: element.clockOut15!,
                      Cl16: element.clockIn16!,
                      Co16: element.clockOut16!,
                      Cl17: element.clockIn17!,
                      Co17: element.clockOut17!,
                      Cl18: element.clockIn18!,
                      Co18: element.clockOut18!,
                      Cl19: element.clockIn19!,
                      Co19: element.clockOut19!,
                      Cl20: element.clockIn20!,
                      Co20: element.clockOut20!,
                      addressIn1: '',
                      addressIn2: '',
                      addressIn3: '',
                      addressIn4: '',
                      addressIn5: '',
                      addressIn6: '',
                      addressIn7: '',
                      addressIn8: '',
                      addressIn9: '',
                      addressIn10: '',
                      addressIn11: '',
                      addressIn12: '',
                      addressIn13: '',
                      addressIn14: '',
                      addressIn15: '',
                      addressIn16: '',
                      addressIn17: '',
                      addressIn18: '',
                      addressIn19: '',
                      addressIn20: '',
                      addressOut1: '',
                      addressOut2: '',
                      addressOut3: '',
                      addressOut4: '',
                      addressOut5: '',
                      addressOut6: '',
                      addressOut7: '',
                      addressOut8: '',
                      addressOut9: '',
                      addressOut10: '',
                      addressOut11: '',
                      addressOut12: '',
                      addressOut13: '',
                      addressOut14: '',
                      addressOut15: '',
                      addressOut16: '',
                      addressOut17: '',
                      addressOut18: '',
                      addressOut19: '',
                      addressOut20: '',
                      Clock_In_Out_Counter: element.clockInOutCounter!,
                      Break_In_Out_Counter: element.breakInOutCounter!,
                      image1: element.image1 != null ? element.image1! : '',
                      image2: element.image2 != null ? element.image2! : '',
                      image3: element.image3 != null ? element.image3! : '',
                      image4: element.image4 != null ? element.image4! : '',
                      image5: element.image5 != null ? element.image5! : '',
                      image6: element.image6 != null ? element.image6! : '',
                      image7: element.image7 != null ? element.image7! : '',
                      image8: element.image8 != null ? element.image8! : '',
                      image9: element.image9 != null ? element.image9! : '',
                      image10: element.image10 != null ? element.image10! : '',
                      image11: element.image11 != null ? element.image11! : '',
                      image12: element.image12 != null ? element.image12! : '',
                      image13: element.image13 != null ? element.image13! : '',
                      image14: element.image14 != null ? element.image14! : '',
                      image15: element.image15 != null ? element.image15! : '',
                      image16: element.image16 != null ? element.image16! : '',
                      image17: element.image17 != null ? element.image17! : '',
                      image18: element.image18 != null ? element.image18! : '',
                      image19: element.image19 != null ? element.image19! : '',
                      image20: element.image20 != null ? element.image20! : '',
                      imageOut1: element.imageOut1 != null ? element.imageOut1! : '',
                      imageOut2: element.imageOut2 != null ? element.imageOut2! : '',
                      imageOut3: element.imageOut3 != null ? element.imageOut3! : '',
                      imageOut4: element.imageOut4 != null ? element.imageOut4! : '',
                      imageOut5: element.imageOut5 != null ? element.imageOut5! : '',
                      imageOut6: element.imageOut6 != null ? element.imageOut6! : '',
                      imageOut7: element.imageOut7 != null ? element.imageOut7! : '',
                      imageOut8: element.imageOut8 != null ? element.imageOut8! : '',
                      imageOut9: element.imageOut9 != null ? element.imageOut9! : '',
                      imageOut10: element.imageOut10 != null ? element.imageOut10! : '',
                      imageOut11: element.imageOut11 != null ? element.imageOut11! : '',
                      imageOut12: element.imageOut12 != null ? element.imageOut12! : '',
                      imageOut13: element.imageOut13 != null ? element.imageOut13! : '',
                      imageOut14: element.imageOut14 != null ? element.imageOut14! : '',
                      imageOut15: element.imageOut15 != null ? element.imageOut15! : '',
                      imageOut16: element.imageOut16 != null ? element.imageOut16! : '',
                      imageOut17: element.imageOut17 != null ? element.imageOut17! : '',
                      imageOut18: element.imageOut18 != null ? element.imageOut18! : '',
                      imageOut19: element.imageOut19 != null ? element.imageOut19! : '',
                      imageOut20: element.imageOut20 != null ? element.imageOut20! : '',
                      Last_Status: element.lastStatus!,
                      lastBreakTableId: element.lastBreakTableId != null ? element.lastBreakTableId! : '',
                      uploadStatus: '1',
                      tabletUserId: element.tabletId != null ? element.tabletId! : '',
                      createAt: DateFormat('yyyy-MM-dd').format(DateTime.now()).toString(),
                      jobType: _checkEmp.jobType,
                    ),
                  );
                }
              });
            }
          }

          if (_empCodeBreakList.length > 0) {
            var empBreakData = await db.rawQuery(
                "SELECT * FROM Attendance_Break WHERE empCode = '${_checkEmp.empCode}' and attendanceDate = '${DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()}'");

            print("Employee BreakData : ${empBreakData.length}");

            if (empBreakData.length > 0) {
              // var _empCheckAttendance = await _databaseService.checkAttendanceEmp1(_empCodeController.text, DateFormat('dd-MM-yyyy').format(DateTime.now()).toString(), userId);
              //
              // print("Break In Out Count : $_breakInOutCounter");
              // print("Break In Out Count1 : ${_empCheckAttendance!.Break_In_Out_Counter}");

              print("Print Else Part");
              await db.delete(
                "Attendance_Break",
                where: "empCode = ? AND attendanceDate = ?",
                whereArgs: [_checkEmp.empCode, DateFormat('dd-MM-yyyy').format(DateTime.now()).toString()],
              );
              // print("Break In Out Employee : ${await db.rawQuery("SELECT * FROM Attendance_Break")}");
              var _checkAttendance =
                  await _databaseService.checkAttendanceEmp1(_checkEmp.empCode, DateFormat('dd-MM-yyyy').format(DateTime.now()).toString());
              _empCodeBreakList.forEach((element) async {
                var insertedId = await _databaseService.insertBreak(
                  AttendanceBreak(
                    empCode: element.employeeId!,
                    empName: '${element.name} ${element.lastname}',
                    attendanceDate: element.date!,
                    breakTime: element.time!,
                    breakEndTime: element.endTime!,
                    uploadStatus: '1',
                    tabletUserId: tabletUserId,
                    createAt: DateFormat('yyyy-MM-dd').format(DateTime.now()).toString(),
                    userId: _checkEmp.userId,
                    breakInAddress: '',
                    breakOutAddress: '',
                    jobType: _checkEmp.jobType,
                    breakInImage: element.breakInImage != null ? element.breakInImage! : '',
                    breakOutImage: element.breakOutImage != null ? element.breakOutImage! : '',
                  ),
                );

                print("Get Attendance Break ID : $insertedId");
                if (element.time != "00:00:00") {
                  await db.rawUpdate('UPDATE Attendance_Employee SET lastBreakTableId = ?,uploadStatus = ? WHERE id = ?',
                      [insertedId.toString(), '1', _checkAttendance!.id]);
                }
              });
            } else {
              var _checkAttendance =
                  await _databaseService.checkAttendanceEmp1(_checkEmp.empCode, DateFormat('dd-MM-yyyy').format(DateTime.now()).toString());
              _empCodeBreakList.forEach((element) async {
                var insertedId = await _databaseService.insertBreak(
                  AttendanceBreak(
                      empCode: element.employeeId!,
                      empName: '${element.name} ${element.lastname}',
                      attendanceDate: element.date!,
                      breakTime: element.time!,
                      breakEndTime: element.endTime!,
                      breakInImage: element.breakInImage != null ? element.breakInImage! : '',
                      breakOutImage: element.breakOutImage != null ? element.breakOutImage! : '',
                      uploadStatus: '1',
                      tabletUserId: _checkEmp.tabletId,
                      createAt: DateFormat('yyyy-MM-dd').format(DateTime.now()).toString(),
                      userId: _checkEmp.userId,
                      breakInAddress: element.breakInImage != null ? element.breakInImage! : '',
                      breakOutAddress: element.breakOutImage != null ? element.breakOutImage! : '',
                      jobType: _checkEmp.jobType),
                );

                if (element.time != "00:00:00") {
                  await db.rawUpdate('UPDATE Attendance_Employee SET lastBreakTableId = ?,uploadStatus = ? WHERE id = ?',
                      [insertedId.toString(), '1', _checkAttendance!.id]);
                }
                // if (element.endTime != "00:00:00") {
                //   await db.rawUpdate('UPDATE Attendance_Employee SET uploadStatus = ? WHERE id = ?', ['1', _checkAttendance!.id]);
                // }
              });
            }
          }

          update();
        }
      } else {
        stopLoadingAttendance();
        startTime = '00:00:00';
        endTime = '00:00:00';
        totalHour = '00:00:00';
        update();
        GetSnackbar(supTitle: checkAttendance.message.toString(), title: "Error");
      }
    } catch (e) {
      stopLoadingAttendance();
      startTime = '00:00:00';
      endTime = '00:00:00';
      totalHour = '00:00:00';
      update();
      GetSnackbar(supTitle: '', title: "Oops! Something went wrong.");
    }
  }

  updateAttendance() {
    todayDate = DateFormat('dd-MM-yyyy').format(DateTime.now());
    update();
    checkAttendance();
  }
}

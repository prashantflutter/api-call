import 'dart:convert';

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../components/get_snackbar.dart';
import '../../components/scrollable_table.dart';
import '../../employee_screen/model/attendace_report/attendance_filter.dart';
import '../../employee_screen/model/attendace_report/attendance_report.dart';

import '../../services/attendance_services.dart';
import '../../utils/constant/app_color.dart';
import '../../utils/constant/app_string.dart';
import '../../utils/constant/text_style.dart';
import '../../utils/sharPreferenceUtils.dart';

class AttendanceReportController extends GetxController {
  var totalBreakHour = 0;
  var totalWorkedHour = 0;
  var totalHour = 0;
  bool loading = false;
  var sharePref = SharedPrefs.instance;

  List<DateTime?> rangeDatePickerValueWithDefaultValue = [
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
  ];

  List<AttendanceData> attendanceList = [];
  List<AttendanceFilter> attendanceFilterList = [];
  List<BreakInOutData> breakInOutList = [];
  List<ClockInOutData> clockInOutList = [];

  PaginationController paginationController = PaginationController(
    rowCount: 0,
    rowsPerPage: 8,
  );

  @override
  void onInit() {
    super.onInit();
    getAttendanceReport('${DateFormat('dd-MM-yyyy').format(DateTime.parse(rangeDatePickerValueWithDefaultValue.first.toString()))}',
        '${DateFormat('dd-MM-yyyy').format(DateTime.parse(rangeDatePickerValueWithDefaultValue.last.toString()))}');
  }

  void NexPage() {
    paginationController!.next();
    update();
  }

  void PreviousPage() {
    paginationController!.previous();
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

  void selectDate(BuildContext context) {
    Dialog alert = Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 30),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GetBuilder<AttendanceReportController>(
            builder: (_) {
              return CalendarDatePicker2(
                  config: CalendarDatePicker2Config(
                    calendarType: CalendarDatePicker2Type.range,
                    selectedDayHighlightColor: kMainColor,
                    weekdayLabelTextStyle: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                    controlsTextStyle: const TextStyle(
                      color: Colors.black,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  value: rangeDatePickerValueWithDefaultValue,
                  onValueChanged: (dates) {
                    rangeDatePickerValueWithDefaultValue = dates;
                    update();
                  });
            },
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
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    getAttendanceReport('${DateFormat('dd-MM-yyyy').format(DateTime.parse(rangeDatePickerValueWithDefaultValue.first.toString()))}',
                        '${DateFormat('dd-MM-yyyy').format(DateTime.parse(rangeDatePickerValueWithDefaultValue.last.toString()))}');
                  },
                  child: Text(
                    'Apply'.toUpperCase(),
                    style: kTextStyle.copyWith(color: kMainColor, fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                )
              ],
            ),
          ),
          SizedBox(
            height: 10,
          )
        ],
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

  getAttendanceReport(String startDate, String endDate) async {
    startLoading();
    try {
      var response = await AttendanceApi.attendanceReport(
          authToken: sharePref.getString(authToken) ?? '', userId: sharePref.getString(userId) ?? '', startDate: startDate, endDate: endDate);
      print("Response Attendance Report : ${response.toString()}");
      AttendanceReport attendanceReport = AttendanceReport.fromJson(json.decode(response.data));
      if (response.statusCode == 200) {
        if (attendanceReport?.success == true) {
          attendanceList.clear();

          attendanceList.addAll((attendanceReport?.data)!.map((x) => AttendanceData.fromJson(x.toJson())).toList());

          breakInOutList.clear();
          clockInOutList.clear();
          attendanceFilterList.clear();
          totalBreakHour = 0;
          totalWorkedHour = 0;
          totalHour = 0;

          if (attendanceList.length > 0) {
            for (int i = 0; i < attendanceList.length; i++) {
              var breakHours = attendanceList[i].totalBreakHours!.split(':');
              var breakFirst = int.parse(breakHours[0].trim()) * 60;
              var breakLast = int.parse(breakHours[1].trim());
              totalBreakHour = totalBreakHour + (breakFirst + breakLast);

              var workedHours = attendanceList[i].totalHours!.split(':');
              var workedFirst = int.parse(workedHours[0].trim()) * 60;
              var workedLast = int.parse(workedHours[1].trim());
              totalWorkedHour = totalWorkedHour + (workedFirst + workedLast);

              var totalHours = attendanceList[i].afterMinusBreakHours!.split(':');
              var totalFirst = int.parse(totalHours[0].trim()) * 60;
              var totalLast = int.parse(totalHours[1].trim());
              totalHour = totalHour + (totalFirst + totalLast);

              if (attendanceList[i].breakData!.length > 0) {
                for (int j = 0; j < attendanceList[i].breakData!.length; j++) {
                  if (attendanceList[i].breakData![j].time != "00:00:00") {
                    breakInOutList.add(
                      BreakInOutData(
                        breakStartTime: attendanceList[i].breakData![j].time,
                        breakEndTime: attendanceList[i].breakData![j].endTime,
                        breakStartImage: attendanceList[i].breakData![j].breakInImage,
                        breakEndImage: attendanceList[i].breakData![j].breakOutImage,
                      ),
                    );
                  }
                }
              }

              if (attendanceList[i].clockIn != "00:00:00" && attendanceList[i].clockIn != null) {
                clockInOutList.add(
                  ClockInOutData(
                    clockInTime: attendanceList[i].clockIn,
                    clockOutTime: attendanceList[i].clockOut,
                    clockInImage: attendanceList[i].image1,
                    clockOutImage: attendanceList[i].imageOut1,
                  ),
                );
              }

              if (attendanceList[i].clockIn2 != "00:00:00" && attendanceList[i].clockIn2 != null) {
                clockInOutList.add(
                  ClockInOutData(
                    clockInTime: attendanceList[i].clockIn2,
                    clockOutTime: attendanceList[i].clockOut2,
                    clockInImage: attendanceList[i].image2,
                    clockOutImage: attendanceList[i].imageOut2,
                  ),
                );
              }

              if (attendanceList[i].clockIn3 != "00:00:00" && attendanceList[i].clockIn3 != null) {
                clockInOutList.add(
                  ClockInOutData(
                    clockInTime: attendanceList[i].clockIn3,
                    clockOutTime: attendanceList[i].clockOut3,
                    clockInImage: attendanceList[i].image3,
                    clockOutImage: attendanceList[i].imageOut3,
                  ),
                );
              }

              if (attendanceList[i].clockIn4 != "00:00:00" && attendanceList[i].clockIn4 != null) {
                clockInOutList.add(
                  ClockInOutData(
                    clockInTime: attendanceList[i].clockIn4,
                    clockOutTime: attendanceList[i].clockOut4,
                    clockInImage: attendanceList[i].image4,
                    clockOutImage: attendanceList[i].imageOut4,
                  ),
                );
              }

              if (attendanceList[i].clockIn5 != "00:00:00" && attendanceList[i].clockIn5 != null) {
                clockInOutList.add(
                  ClockInOutData(
                    clockInTime: attendanceList[i].clockIn5,
                    clockOutTime: attendanceList[i].clockOut5,
                    clockInImage: attendanceList[i].image5,
                    clockOutImage: attendanceList[i].imageOut5,
                  ),
                );
              }

              if (attendanceList[i].clockIn6 != "00:00:00" && attendanceList[i].clockIn6 != null) {
                clockInOutList.add(
                  ClockInOutData(
                    clockInTime: attendanceList[i].clockIn6,
                    clockOutTime: attendanceList[i].clockOut6,
                    clockInImage: attendanceList[i].image6,
                    clockOutImage: attendanceList[i].imageOut6,
                  ),
                );
              }

              if (attendanceList[i].clockIn7 != "00:00:00" && attendanceList[i].clockIn7 != null) {
                clockInOutList.add(
                  ClockInOutData(
                    clockInTime: attendanceList[i].clockIn7,
                    clockOutTime: attendanceList[i].clockOut7,
                    clockInImage: attendanceList[i].image7,
                    clockOutImage: attendanceList[i].imageOut7,
                  ),
                );
              }

              if (attendanceList[i].clockIn8 != "00:00:00" && attendanceList[i].clockIn8 != null) {
                clockInOutList.add(
                  ClockInOutData(
                    clockInTime: attendanceList[i].clockIn8,
                    clockOutTime: attendanceList[i].clockOut8,
                    clockInImage: attendanceList[i].image8,
                    clockOutImage: attendanceList[i].imageOut8,
                  ),
                );
              }

              if (attendanceList[i].clockIn9 != "00:00:00" && attendanceList[i].clockIn9 != null) {
                clockInOutList.add(
                  ClockInOutData(
                    clockInTime: attendanceList[i].clockIn9,
                    clockOutTime: attendanceList[i].clockOut9,
                    clockInImage: attendanceList[i].image9,
                    clockOutImage: attendanceList[i].imageOut9,
                  ),
                );
              }

              if (attendanceList[i].clockIn10 != "00:00:00" && attendanceList[i].clockIn10 != null) {
                clockInOutList.add(
                  ClockInOutData(
                    clockInTime: attendanceList[i].clockIn10,
                    clockOutTime: attendanceList[i].clockOut10,
                    clockInImage: attendanceList[i].image10,
                    clockOutImage: attendanceList[i].imageOut10,
                  ),
                );
              }

              if (attendanceList[i].clockIn11 != "00:00:00" && attendanceList[i].clockIn11 != null) {
                clockInOutList.add(
                  ClockInOutData(
                    clockInTime: attendanceList[i].clockIn11,
                    clockOutTime: attendanceList[i].clockOut11,
                    clockInImage: attendanceList[i].image11,
                    clockOutImage: attendanceList[i].imageOut11,
                  ),
                );
              }

              if (attendanceList[i].clockIn12 != "00:00:00" && attendanceList[i].clockIn12 != null) {
                clockInOutList.add(
                  ClockInOutData(
                    clockInTime: attendanceList[i].clockIn12,
                    clockOutTime: attendanceList[i].clockOut12,
                    clockInImage: attendanceList[i].image12,
                    clockOutImage: attendanceList[i].imageOut12,
                  ),
                );
              }

              if (attendanceList[i].clockIn13 != "00:00:00" && attendanceList[i].clockIn13 != null) {
                clockInOutList.add(
                  ClockInOutData(
                    clockInTime: attendanceList[i].clockIn13,
                    clockOutTime: attendanceList[i].clockOut13,
                    clockInImage: attendanceList[i].image13,
                    clockOutImage: attendanceList[i].imageOut13,
                  ),
                );
              }

              if (attendanceList[i].clockIn14 != "00:00:00" && attendanceList[i].clockIn14 != null) {
                clockInOutList.add(
                  ClockInOutData(
                    clockInTime: attendanceList[i].clockIn14,
                    clockOutTime: attendanceList[i].clockOut14,
                    clockInImage: attendanceList[i].image14,
                    clockOutImage: attendanceList[i].imageOut14,
                  ),
                );
              }

              if (attendanceList[i].clockIn15 != "00:00:00" && attendanceList[i].clockIn15 != null) {
                clockInOutList.add(
                  ClockInOutData(
                    clockInTime: attendanceList[i].clockIn15,
                    clockOutTime: attendanceList[i].clockOut15,
                    clockInImage: attendanceList[i].image15,
                    clockOutImage: attendanceList[i].imageOut15,
                  ),
                );
              }

              if (attendanceList[i].clockIn16 != "00:00:00" && attendanceList[i].clockIn16 != null) {
                clockInOutList.add(
                  ClockInOutData(
                    clockInTime: attendanceList[i].clockIn16,
                    clockOutTime: attendanceList[i].clockOut16,
                    clockInImage: attendanceList[i].image16,
                    clockOutImage: attendanceList[i].imageOut16,
                  ),
                );
              }

              if (attendanceList[i].clockIn17 != "00:00:00" && attendanceList[i].clockIn17 != null) {
                clockInOutList.add(
                  ClockInOutData(
                    clockInTime: attendanceList[i].clockIn17,
                    clockOutTime: attendanceList[i].clockOut17,
                    clockInImage: attendanceList[i].image17,
                    clockOutImage: attendanceList[i].imageOut17,
                  ),
                );
              }

              if (attendanceList[i].clockIn18 != "00:00:00" && attendanceList[i].clockIn18 != null) {
                clockInOutList.add(
                  ClockInOutData(
                    clockInTime: attendanceList[i].clockIn18,
                    clockOutTime: attendanceList[i].clockOut18,
                    clockInImage: attendanceList[i].image18,
                    clockOutImage: attendanceList[i].imageOut18,
                  ),
                );
              }

              if (attendanceList[i].clockIn19 != "00:00:00" && attendanceList[i].clockIn19 != null) {
                clockInOutList.add(
                  ClockInOutData(
                    clockInTime: attendanceList[i].clockIn19,
                    clockOutTime: attendanceList[i].clockOut19,
                    clockInImage: attendanceList[i].image19,
                    clockOutImage: attendanceList[i].imageOut19,
                  ),
                );
              }

              if (attendanceList[i].clockIn20 != "00:00:00" && attendanceList[i].clockIn20 != null) {
                clockInOutList.add(
                  ClockInOutData(
                    clockInTime: attendanceList[i].clockIn20,
                    clockOutTime: attendanceList[i].clockOut20,
                    clockInImage: attendanceList[i].image20,
                    clockOutImage: attendanceList[i].imageOut20,
                  ),
                );
              }

              update();

              attendanceFilterList.add(
                AttendanceFilter(
                    empCode: attendanceList[i].employeeId,
                    empName: attendanceList[i].name,
                    deviceName: attendanceList[i].tabletName,
                    date: attendanceList[i].date,
                    totalBreakHour: attendanceList[i].totalBreakHours,
                    workedHour: attendanceList[i].totalHours,
                    finalTotalHour: attendanceList[i].afterMinusBreakHours,
                    clockInOutData: clockInOutList.toList(),
                    breakInOutData: breakInOutList.toList()),
              );

              breakInOutList.clear();
              clockInOutList.clear();
            }
          }

          paginationController = PaginationController(
            rowCount: attendanceFilterList.length,
            rowsPerPage: 8,
          );

          stopLoading();

          update();
        }
      } else {
        attendanceFilterList.clear();
        paginationController = PaginationController(
          rowCount: attendanceFilterList.length,
          rowsPerPage: 8,
        );
        stopLoading();
        update();
        GetSnackbar(supTitle: attendanceReport.message.toString(), title: "Error");
      }
    } catch (error) {
      stopLoading();
      GetSnackbar(supTitle: '', title: "Oops! Something went wrong.");
    }
  }

  getBottomAttendenceWidget() {
    return [
      Container(
        width: 150,
        height: 45,
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        alignment: Alignment.center,
        child: Text('Total', style: kTextStyle.copyWith(fontWeight: FontWeight.bold, color: kTitleColor)),
      ),
      // _getBottomItemWidget('', 100),
      Container(
        width: 150,
        height: 45,
        decoration: const BoxDecoration(
          border: Border(
            left: BorderSide(
              color: Colors.black38,
              width: 0.5,
            ),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        alignment: Alignment.center,
        child: Text('', style: kTextStyle.copyWith(fontWeight: FontWeight.bold, color: kTitleColor)),
      ),

      _getBottomItemAttendenceWidget('', 220),
      _getBottomItemAttendenceWidget('', 220),
      // _getBottomItemWidget('00HH:00MM', 100),
      Container(
        width: 100,
        height: 45,
        decoration: const BoxDecoration(
          border: Border(
            left: BorderSide(
              color: Colors.black38,
              width: 0.5,
            ),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        alignment: Alignment.center,
        child: Text(
          '${formatDuration(Duration(minutes: totalBreakHour!)).toString()}',
          style: kTextStyle.copyWith(
            fontWeight: FontWeight.bold,
            color: kTitleColor,
          ),
        ),
      ),
      Container(
        width: 100,
        height: 45,
        decoration: const BoxDecoration(
          border: Border(
            left: BorderSide(
              color: Colors.black38,
              width: 0.5,
            ),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        alignment: Alignment.center,
        child: Text(
          '${formatDuration(
            Duration(
              minutes: totalWorkedHour,
            ),
          ).toString()}',
          style: kTextStyle.copyWith(
            fontWeight: FontWeight.bold,
            color: kTitleColor,
          ),
        ),
      ),
      // _getBottomItemWidget('00HH:00MM', 100),
      Container(
        width: 100,
        height: 45,
        decoration: const BoxDecoration(
          border: Border(
            left: BorderSide(
              color: Colors.black38,
              width: 0.5,
            ),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        alignment: Alignment.center,
        child: Text(
          '${formatDuration(
            Duration(minutes: totalHour),
          ).toString()}',
          style: kTextStyle.copyWith(
            fontWeight: FontWeight.bold,
            color: kTitleColor,
          ),
        ),
      )
    ];
  }

  getAttendenceTitleWidget() {
    return [
      // _getTitleItemWidget('Employee Name', 150),
      Container(
        width: 150,
        height: 45,
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        alignment: Alignment.center,
        child: Text('Date', style: kTextStyle.copyWith(fontWeight: FontWeight.bold, color: kTitleColor)),
      ),
      _getTitleAttendenceItemWidget('Branch', 150),
      _getTitleAttendenceItemWidget('Clock In | Clock Out', 220),
      _getTitleAttendenceItemWidget('Break In | Break Out', 220),
      _getTitleAttendenceItemWidget('Break Hours', 100),
      _getTitleAttendenceItemWidget('Worked Hours', 100),
      Container(
        width: 100,
        height: 45,
        decoration: const BoxDecoration(
          border: Border(
            left: BorderSide(
              color: Colors.black38,
              width: 0.5,
            ),
            right: BorderSide(
              color: Colors.black38,
              width: 0.5,
            ),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        alignment: Alignment.center,
        child: Text('Total Hours', style: kTextStyle.copyWith(fontWeight: FontWeight.bold, color: kTitleColor)),
      )
    ];
  }

  String formatDuration(Duration duration) {
    String hours = duration.inHours.toString().padLeft(0, '2');
    String minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    // String seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "${hours}H : ${minutes}M";
  }

  Widget _getBottomItemAttendenceWidget(String label, double width) {
    return Container(
      width: width,
      height: 45,
      decoration: const BoxDecoration(
        // color: Colors.red,
        border: Border(
          bottom: BorderSide(
            color: Colors.black38,
            width: 0.5,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
      alignment: Alignment.center,
      child: Text(label, style: kTextStyle.copyWith(fontWeight: FontWeight.bold, color: kTitleColor)),
    );
  }

  Widget _getTitleAttendenceItemWidget(String label, double width) {
    return Container(
      width: width,
      height: 45,
      decoration: const BoxDecoration(
        border: Border(
          left: BorderSide(
            color: Colors.black38,
            width: 0.5,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(5, 0, 0, 0),
      alignment: Alignment.center,
      child: Text(label, style: kTextStyle.copyWith(fontWeight: FontWeight.bold, color: kTitleColor)),
    );
  }
}

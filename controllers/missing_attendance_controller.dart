import 'dart:convert';

import 'package:calendar_date_picker2/calendar_date_picker2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/default_button.dart';
import '../../components/get_snackbar.dart';
import '../../components/scrollable_table.dart';
import '../../employee_screen/model/missing_attendance_report/missing_attendance_filter.dart';
import '../../employee_screen/model/missing_attendance_report/missing_attendance_inform.dart';
import '../../employee_screen/model/missing_attendance_report/missing_attendance_report.dart';
import '../../services/attendance_services.dart';
import '../../utils/constant/app_color.dart';
import '../../utils/constant/app_string.dart';
import '../../utils/constant/text_style.dart';
import '../../utils/sharPreferenceUtils.dart';

class MissingAttendanceController extends GetxController {
  var sharePref = SharedPrefs.instance;
  bool loading = false;
  bool loadingMissPunch = false;

  List<DateTime?> rangeDatePickerValueWithDefaultValue = [
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
    DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day),
  ];

  PaginationController paginationController = PaginationController(
    rowCount: 0,
    rowsPerPage: 8,
  );

  List<MissingAttendanceData> missingAttendanceList = [];
  List<MissingAttendanceFilter> missingAttendanceFilterList = [];
  List<MissingBreakInOutData> missingBreakInOutList = [];
  List<MissingClockInOutData> missingClockInOutList = [];

  final fromKey = GlobalKey<FormState>();
  TextEditingController noteController = TextEditingController();

  @override
  void onInit() {
    missingAttendanceReport('${DateFormat('dd-MM-yyyy').format(DateTime.parse(rangeDatePickerValueWithDefaultValue.first.toString()))}',
        '${DateFormat('dd-MM-yyyy').format(DateTime.parse(rangeDatePickerValueWithDefaultValue.last.toString()))}');
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

  void NexPage() {
    paginationController!.next();
    update();
  }

  void PreviousPage() {
    paginationController!.previous();
    update();
  }

  void startLoadingMissPunch() {
    loadingMissPunch = true;
    update();
  }

  void stopLoadingMissPunch() {
    loadingMissPunch = false;
    update();
  }

  missingAttendanceReport(String startDate, String endDate) async {
    startLoading();
    try {
      var response = await AttendanceApi.missingAttendanceReport(
          authToken: sharePref.getString(authToken) ?? '', userId: sharePref.getString(userId) ?? '', startDate: startDate, endDate: endDate);
      print("Response Attendance Report : ${response.toString()}");
      MissingAttendanceReport missingAttendanceReport = MissingAttendanceReport.fromJson(json.decode(response.data));
      if (response.statusCode == 200) {
        if (missingAttendanceReport?.success == true) {
          missingAttendanceList.clear();
          missingAttendanceList.addAll((missingAttendanceReport?.data)!.map((x) => MissingAttendanceData.fromJson(x.toJson())).toList());

          missingBreakInOutList.clear();
          missingClockInOutList.clear();
          missingAttendanceFilterList.clear();

          if (missingAttendanceList.length > 0) {
            for (int i = 0; i < missingAttendanceList.length; i++) {
              if (missingAttendanceList[i].breakData!.length > 0) {
                for (int j = 0; j < missingAttendanceList[i].breakData!.length; j++) {
                  if (missingAttendanceList[i].breakData![j].time != "00:00:00") {
                    missingBreakInOutList.add(
                      MissingBreakInOutData(
                          breakStartTime: missingAttendanceList[i].breakData![j].time,
                          breakEndTime: missingAttendanceList[i].breakData![j].endTime,
                          missingBreakInOut: missingAttendanceList[i].breakData![j].endTime == "00:00:00" ? true : false),
                    );
                  }
                }
              }

              if (missingAttendanceList[i].clockIn != "00:00:00" && missingAttendanceList[i].clockIn != null) {
                missingClockInOutList.add(
                  MissingClockInOutData(
                      clockInTime: missingAttendanceList[i].clockIn,
                      clockOutTime: missingAttendanceList[i].clockOut,
                      missingClockInOut: missingAttendanceList[i].missingPunch == "clock_out" ? true : false),
                );
              }

              if (missingAttendanceList[i].clockIn2 != "00:00:00" && missingAttendanceList[i].clockIn2 != null) {
                missingClockInOutList.add(
                  MissingClockInOutData(
                      clockInTime: missingAttendanceList[i].clockIn2,
                      clockOutTime: missingAttendanceList[i].clockOut2,
                      missingClockInOut: missingAttendanceList[i].missingPunch == "clock_out_2" ? true : false),
                );
              }

              if (missingAttendanceList[i].clockIn3 != "00:00:00" && missingAttendanceList[i].clockIn3 != null) {
                missingClockInOutList.add(
                  MissingClockInOutData(
                    clockInTime: missingAttendanceList[i].clockIn3,
                    clockOutTime: missingAttendanceList[i].clockOut3,
                    missingClockInOut: missingAttendanceList[i].missingPunch == "clock_out_3" ? true : false,
                  ),
                );
              }

              if (missingAttendanceList[i].clockIn4 != "00:00:00" && missingAttendanceList[i].clockIn4 != null) {
                missingClockInOutList.add(
                  MissingClockInOutData(
                    clockInTime: missingAttendanceList[i].clockIn4,
                    clockOutTime: missingAttendanceList[i].clockOut4,
                    missingClockInOut: missingAttendanceList[i].missingPunch == "clock_out_4" ? true : false,
                  ),
                );
              }

              if (missingAttendanceList[i].clockIn5 != "00:00:00" && missingAttendanceList[i].clockIn5 != null) {
                missingClockInOutList.add(
                  MissingClockInOutData(
                    clockInTime: missingAttendanceList[i].clockIn5,
                    clockOutTime: missingAttendanceList[i].clockOut5,
                    missingClockInOut: missingAttendanceList[i].missingPunch == "clock_out_5" ? true : false,
                  ),
                );
              }

              if (missingAttendanceList[i].clockIn6 != "00:00:00" && missingAttendanceList[i].clockIn6 != null) {
                missingClockInOutList.add(
                  MissingClockInOutData(
                    clockInTime: missingAttendanceList[i].clockIn6,
                    clockOutTime: missingAttendanceList[i].clockOut6,
                    missingClockInOut: missingAttendanceList[i].missingPunch == "clock_out_6" ? true : false,
                  ),
                );
              }

              if (missingAttendanceList[i].clockIn7 != "00:00:00" && missingAttendanceList[i].clockIn7 != null) {
                missingClockInOutList.add(
                  MissingClockInOutData(
                    clockInTime: missingAttendanceList[i].clockIn7,
                    clockOutTime: missingAttendanceList[i].clockOut7,
                    missingClockInOut: missingAttendanceList[i].missingPunch == "clock_out_7" ? true : false,
                  ),
                );
              }

              if (missingAttendanceList[i].clockIn8 != "00:00:00" && missingAttendanceList[i].clockIn8 != null) {
                missingClockInOutList.add(
                  MissingClockInOutData(
                    clockInTime: missingAttendanceList[i].clockIn8,
                    clockOutTime: missingAttendanceList[i].clockOut8,
                    missingClockInOut: missingAttendanceList[i].missingPunch == "clock_out_8" ? true : false,
                  ),
                );
              }

              if (missingAttendanceList[i].clockIn9 != "00:00:00" && missingAttendanceList[i].clockIn9 != null) {
                missingClockInOutList.add(
                  MissingClockInOutData(
                    clockInTime: missingAttendanceList[i].clockIn9,
                    clockOutTime: missingAttendanceList[i].clockOut9,
                    missingClockInOut: missingAttendanceList[i].missingPunch == "clock_out_9" ? true : false,
                  ),
                );
              }

              if (missingAttendanceList[i].clockIn10 != "00:00:00" && missingAttendanceList[i].clockIn10 != null) {
                missingClockInOutList.add(
                  MissingClockInOutData(
                    clockInTime: missingAttendanceList[i].clockIn10,
                    clockOutTime: missingAttendanceList[i].clockOut10,
                    missingClockInOut: missingAttendanceList[i].missingPunch == "clock_out_10" ? true : false,
                  ),
                );
              }

              if (missingAttendanceList[i].clockIn11 != "00:00:00" && missingAttendanceList[i].clockIn11 != null) {
                missingClockInOutList.add(
                  MissingClockInOutData(
                    clockInTime: missingAttendanceList[i].clockIn11,
                    clockOutTime: missingAttendanceList[i].clockOut11,
                    missingClockInOut: missingAttendanceList[i].missingPunch == "clock_out_11" ? true : false,
                  ),
                );
              }

              if (missingAttendanceList[i].clockIn12 != "00:00:00" && missingAttendanceList[i].clockIn12 != null) {
                missingClockInOutList.add(
                  MissingClockInOutData(
                    clockInTime: missingAttendanceList[i].clockIn12,
                    clockOutTime: missingAttendanceList[i].clockOut12,
                    missingClockInOut: missingAttendanceList[i].missingPunch == "clock_out_12" ? true : false,
                  ),
                );
              }

              if (missingAttendanceList[i].clockIn13 != "00:00:00" && missingAttendanceList[i].clockIn13 != null) {
                missingClockInOutList.add(
                  MissingClockInOutData(
                    clockInTime: missingAttendanceList[i].clockIn13,
                    clockOutTime: missingAttendanceList[i].clockOut13,
                    missingClockInOut: missingAttendanceList[i].missingPunch == "clock_out_13" ? true : false,
                  ),
                );
              }

              if (missingAttendanceList[i].clockIn14 != "00:00:00" && missingAttendanceList[i].clockIn14 != null) {
                missingClockInOutList.add(
                  MissingClockInOutData(
                    clockInTime: missingAttendanceList[i].clockIn14,
                    clockOutTime: missingAttendanceList[i].clockOut14,
                    missingClockInOut: missingAttendanceList[i].missingPunch == "clock_out_14" ? true : false,
                  ),
                );
              }

              if (missingAttendanceList[i].clockIn15 != "00:00:00" && missingAttendanceList[i].clockIn15 != null) {
                missingClockInOutList.add(
                  MissingClockInOutData(
                    clockInTime: missingAttendanceList[i].clockIn15,
                    clockOutTime: missingAttendanceList[i].clockOut15,
                    missingClockInOut: missingAttendanceList[i].missingPunch == "clock_out_15" ? true : false,
                  ),
                );
              }

              if (missingAttendanceList[i].clockIn16 != "00:00:00" && missingAttendanceList[i].clockIn16 != null) {
                missingClockInOutList.add(
                  MissingClockInOutData(
                    clockInTime: missingAttendanceList[i].clockIn16,
                    clockOutTime: missingAttendanceList[i].clockOut16,
                    missingClockInOut: missingAttendanceList[i].missingPunch == "clock_out_16" ? true : false,
                  ),
                );
              }

              if (missingAttendanceList[i].clockIn17 != "00:00:00" && missingAttendanceList[i].clockIn17 != null) {
                missingClockInOutList.add(
                  MissingClockInOutData(
                    clockInTime: missingAttendanceList[i].clockIn17,
                    clockOutTime: missingAttendanceList[i].clockOut17,
                    missingClockInOut: missingAttendanceList[i].missingPunch == "clock_out_17" ? true : false,
                  ),
                );
              }

              if (missingAttendanceList[i].clockIn18 != "00:00:00" && missingAttendanceList[i].clockIn18 != null) {
                missingClockInOutList.add(
                  MissingClockInOutData(
                    clockInTime: missingAttendanceList[i].clockIn18,
                    clockOutTime: missingAttendanceList[i].clockOut18,
                    missingClockInOut: missingAttendanceList[i].missingPunch == "clock_out_18" ? true : false,
                  ),
                );
              }

              if (missingAttendanceList[i].clockIn19 != "00:00:00" && missingAttendanceList[i].clockIn19 != null) {
                missingClockInOutList.add(
                  MissingClockInOutData(
                    clockInTime: missingAttendanceList[i].clockIn19,
                    clockOutTime: missingAttendanceList[i].clockOut19,
                    missingClockInOut: missingAttendanceList[i].missingPunch == "clock_out_19" ? true : false,
                  ),
                );
              }

              if (missingAttendanceList[i].clockIn20 != "00:00:00" && missingAttendanceList[i].clockIn20 != null) {
                missingClockInOutList.add(
                  MissingClockInOutData(
                    clockInTime: missingAttendanceList[i].clockIn20,
                    clockOutTime: missingAttendanceList[i].clockOut20,
                    missingClockInOut: missingAttendanceList[i].missingPunch == "clock_out_20" ? true : false,
                  ),
                );
              }

              update();

              missingAttendanceFilterList.add(
                MissingAttendanceFilter(
                    id: missingAttendanceList[i].id,
                    empCode: missingAttendanceList[i].employeeId,
                    empName: missingAttendanceList[i].name,
                    deviceName: missingAttendanceList[i].tabletName,
                    date: missingAttendanceList[i].date,
                    totalBreakHour: missingAttendanceList[i].totalBreakHours,
                    workedHour: missingAttendanceList[i].totalHours,
                    finalTotalHour: missingAttendanceList[i].afterMinusBreakHours,
                    missingPunch: missingAttendanceList[i].missingPunch,
                    missingBreakPunch: missingAttendanceList[i].missingBreakPunch,
                    missingNote: missingAttendanceList[i].missingNote,
                    clockInOutData: missingClockInOutList.toList(),
                    breakInOutData: missingBreakInOutList.toList()),
              );

              missingBreakInOutList.clear();
              missingClockInOutList.clear();
            }
          }

          paginationController = PaginationController(
            rowCount: missingAttendanceFilterList.length,
            rowsPerPage: 8,
          );

          stopLoading();

          update();
        }
      } else {
        missingAttendanceFilterList.clear();
        paginationController = PaginationController(
          rowCount: missingAttendanceFilterList.length,
          rowsPerPage: 8,
        );
        stopLoading();
        update();
        GetSnackbar(supTitle: missingAttendanceReport.message.toString(), title: "Error");
      }
    } catch (error) {
      stopLoading();
      GetSnackbar(supTitle: '', title: "Oops! Something went wrong.");
    }
  }

  void selectDate(BuildContext context) {
    Dialog alert = Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 30),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          GetBuilder<MissingAttendanceController>(
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
                    missingAttendanceReport(
                        '${DateFormat('dd-MM-yyyy').format(DateTime.parse(rangeDatePickerValueWithDefaultValue.first.toString()))}',
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

  void missingAttendanceInform(String id,BuildContext context) {
    Dialog alert = Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 30),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child:Form(
          key: fromKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 20,
              ),
              Container(
                width: double.infinity,
                alignment: Alignment.centerLeft,
                child: Text(
                  "Miss Punch Note",
                  style: kTextStyle.copyWith(
                    color: kTitleColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(
                height: 15,
              ),
              GetBuilder<MissingAttendanceController>(builder: (_){
                return AppTextField(
                  textFieldType: TextFieldType.MULTILINE,
                  controller: noteController,
                  validator: (value) {
                    if (value.toString().length == 0) {
                      return 'This field is required';
                    } else {
                      return null;
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Miss punch note',
                    hintText: 'something write about miss punch',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    border: OutlineInputBorder(),
                  ),
                );
              }),
              SizedBox(
                height: 20,
              ),
              GetBuilder<MissingAttendanceController>(builder: (_){
                return loadingMissPunch ? CircularProgressIndicator() : ButtonGlobal(
                  text: 'Submit',
                  backgroundColor: kMainColor,
                  onPressed: () {
                    if (fromKey.currentState!.validate()) {
                      String missPunchNote = noteController.text.trim();

                      missNote(context,id,missPunchNote);

                    }
                  },
                );
              }),
              SizedBox(
                height: 20,
              ),
            ],
          ),
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

  missNote(BuildContext buildContext,String id,String missPunchNote) async {
    startLoadingMissPunch();
    try {
      var response = await AttendanceApi.missingPunchNote(authToken:sharePref.getString(authToken) ?? '', userId: sharePref.getString(userId) ?? '',id: id, missNote: missPunchNote,);
      MissingAttendanceNote missingAttendanceNote = MissingAttendanceNote.fromJson(json.decode(response.data));

      print("Response Employee Check Attendance => : $response");

      if (response.statusCode == 200) {
        if (missingAttendanceNote.success == true) {
          stopLoadingMissPunch();
          Navigator.of(buildContext).pop();
          GetSnackbar(supTitle: missingAttendanceNote.message.toString(), title: "Success");

        }else{
          stopLoadingMissPunch();
          GetSnackbar(supTitle: missingAttendanceNote.message.toString(), title: "Error");
        }
      } else {
        stopLoadingMissPunch();
        GetSnackbar(supTitle: missingAttendanceNote.message.toString(), title: "Error");
      }
    } catch (e) {

      stopLoadingMissPunch();
      GetSnackbar(supTitle: '', title: "Oops! Something went wrong.");
    }
  }

  getMissingAttendenceTitleWidget() {
    return [
      // _getTitleItemWidget('Employee Name', 150),
      Container(
        width: 150,
        height: 45,
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        alignment: Alignment.center,
        child: Text('Employee id', style: kTextStyle.copyWith(fontWeight: FontWeight.bold, color: kTitleColor)),
      ),
      _getTitleMissingAttendenceItemWidget('Employee Name', 150),
      _getTitleMissingAttendenceItemWidget('Missing Punch	', 150),
      _getTitleMissingAttendenceItemWidget('Tablet Name', 150),
      _getTitleMissingAttendenceItemWidget('Date', 150),
      _getTitleMissingAttendenceItemWidget('Clock In | Clock Out', 220),
      Container(
        width: 220,
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
        child: Text('Break In | Break Out', style: kTextStyle.copyWith(fontWeight: FontWeight.bold, color: kTitleColor)),
      )
    ];
  }
  Widget _getTitleMissingAttendenceItemWidget(String label, double width) {
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

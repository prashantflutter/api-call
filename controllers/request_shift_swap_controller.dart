import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/default_button.dart';
import '../../components/get_snackbar.dart';
import '../../employee_screen/model/rotas/rotas.dart';
import '../../employee_screen/model/rotas/rotas_transfer.dart';
import '../../services/rotas_services.dart';
import '../../utils/constant/app_color.dart';
import '../../utils/constant/app_string.dart';
import '../../utils/constant/text_style.dart';
import '../../utils/sharPreferenceUtils.dart';

class RequestShiftSwapController extends GetxController {
  var sharePref = SharedPrefs.instance;

  bool loading = false;
  bool loadingRequestShift = false;

  var employeeName;
  var employeeProfilePic;
  var designation;

  List<RotasData> rotasList = [];

  var weekStartDate = '';
  var weekEndDate = '';
  var totalWeekHour = '0.0';
  final fromKey = GlobalKey<FormState>();
  TextEditingController reasonController = TextEditingController();
  var selectDate;

  @override
  void onInit() {
    employeeName = sharePref.getString(userName) ?? '';
    employeeProfilePic = sharePref.getString(profilePicture);
    designation = sharePref.getString('designation');
    update();

    getERota();
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

  void startLoadingRequestShift() {
    loadingRequestShift = true;
    update();
  }

  void stopLoadingRequestShift() {
    loadingRequestShift = false;
    update();
  }

  getERota() async {
    startLoading();
    try {
      var response = await RotasApi.getRotasWork(authToken: sharePref.getString(authToken) ?? '', userId: sharePref.getString(userId) ?? '',weekStartDate:weekStartDate,weekEndDate:weekEndDate);
      Rotas rotas = Rotas.fromJson(json.decode(response.data));

      print("Response ERotas => : $response");

      if (response.statusCode == 200) {
        if (rotas.success == true) {
          weekStartDate = rotas.startDate != null ? rotas.startDate! : '';
          weekEndDate = rotas.endDate != null ? rotas.endDate! : '';
          totalWeekHour = rotas.totalHoursOfWeek != null ? rotas.totalHoursOfWeek! : '0.0';
          rotasList.clear();
          rotasList.addAll((rotas?.data)!.map((x) => RotasData.fromJson(x.toJson())).toList());
          update();

          stopLoading();
        } else {
          stopLoading();
          GetSnackbar(supTitle: rotas.message.toString(), title: "Error");
        }
      } else {
        stopLoading();
        GetSnackbar(supTitle: rotas.message.toString(), title: "Error");
      }
    } catch (e) {
      print("Error : ${e.toString()}");
      stopLoading();
      GetSnackbar(supTitle: '', title: "Oops! Something went wrong.");
    }
  }

  getPreviousDate() {
    var previousWeekDate = DateTime.parse(weekStartDate).add(Duration(days: -7));

    weekStartDate =  DateFormat('yyyy-MM-dd').format(getDate(previousWeekDate.subtract(Duration(days: previousWeekDate.weekday - 1))));
    weekEndDate = DateFormat('yyyy-MM-dd').format(getDate(previousWeekDate.add(Duration(days: DateTime.daysPerWeek - previousWeekDate.weekday))));
    print('Start of week: ${getDate(previousWeekDate.subtract(Duration(days: previousWeekDate.weekday - 1)))}');
    print('End of week: ${getDate(previousWeekDate.add(Duration(days: DateTime.daysPerWeek - previousWeekDate.weekday)))}');

    print("Previous Week Date : ${previousWeekDate}");

    getERota();

    update();
  }

  getNextDate() {
    var nextWeekDate = DateTime.parse(weekStartDate).add(Duration(days: 7));

    weekStartDate =  DateFormat('yyyy-MM-dd').format(getDate(nextWeekDate.subtract(Duration(days: nextWeekDate.weekday - 1))));
    weekEndDate = DateFormat('yyyy-MM-dd').format(getDate(nextWeekDate.add(Duration(days: DateTime.daysPerWeek - nextWeekDate.weekday))));
    print('Start of week: ${getDate(nextWeekDate.subtract(Duration(days: nextWeekDate.weekday - 1)))}');
    print('End of week: ${getDate(nextWeekDate.add(Duration(days: DateTime.daysPerWeek - nextWeekDate.weekday)))}');

    print("Next Week Date : ${nextWeekDate}");
    getERota();
    update();
  }

  DateTime getDate(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  void onClose() {
    super.onClose();
  }

  shiftSwapDialog(BuildContext context, String currentDate, String selectedTransferDate, String reason) {
    reasonController.text = reason;
    rotasList.forEachIndexed((element, indexId) {
      if (rotasList[indexId].date == selectedTransferDate) {
        rotasList[indexId].isSelect = true;
        selectDate = selectedTransferDate;
      } else {
        rotasList[indexId].isSelect = false;
      }

    });
    update();
    Dialog alert = Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 30),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Form(
        key: fromKey,
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 30),
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
                  "Request Shift Swap",
                  style: kTextStyle.copyWith(
                    color: kTitleColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              SizedBox(
                height: 20,
              ),
              GetBuilder<RequestShiftSwapController>(builder: (_) {
                return AppTextField(
                  textFieldType: TextFieldType.MULTILINE,
                  controller: reasonController,
                  validator: (value) {
                    if (value.toString().length == 0) {
                      return 'This field is required';
                    } else {
                      return null;
                    }
                  },
                  decoration: const InputDecoration(
                    labelText: 'Reason',
                    hintText: 'something write...',
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    border: OutlineInputBorder(),
                  ),
                );
              }),
              SizedBox(
                height: 20,
              ),
              GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 2.5,
                  ),
                  itemCount: rotasList.length,
                  shrinkWrap: true,

                  itemBuilder: (context, index) {
                    return Container(
                      margin: EdgeInsets.symmetric(horizontal: 10,vertical: 2),
                      child: GetBuilder<RequestShiftSwapController>(builder: (_) {
                        return Container(

                          decoration: BoxDecoration(
                            border: Border.all(color: rotasList[index].isSelect == true ? kMainColor : Colors.transparent),
                          ),
                          padding: EdgeInsets.all(2),
                          child: TextButton(
                            style: TextButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                              disabledForegroundColor: Colors.white,
                              backgroundColor: rotasList[index].status == 0 ? kMainColor : kMainColor.withOpacity(0.30),
                            ),
                            onPressed: () {
                              if (rotasList[index].status == 0) {
                                rotasList.forEachIndexed((element, indexId) {
                                  if (indexId == index) {
                                    rotasList[indexId].isSelect = true;
                                    selectDate = rotasList[indexId].date;
                                  } else {
                                    rotasList[indexId].isSelect = false;
                                  }
                                });
                              }
                              update();
                            },
                            child: Text(
                              "${rotasList[index].date}",
                              style: kTextStyle.copyWith(color: kWhiteColor, fontWeight: FontWeight.w600),
                            ),
                          ),
                        );
                      }),
                    );
                  }),
              SizedBox(
                height: 20,
              ),
              GetBuilder<RequestShiftSwapController>(builder: (_) {
                return loadingRequestShift
                    ? CircularProgressIndicator()
                    : ButtonGlobal(
                        text: 'Submit',
                        backgroundColor: kMainColor,
                        onPressed: () {
                          if (fromKey.currentState!.validate()) {
                            String reason = reasonController.text.trim();
                            if (selectDate != null) {
                              // print("Reason : ${reason} -------- Select Date : ${selectDate}");
                              rotasTransfer(context, currentDate, selectDate, reason);
                            } else {
                              GetSnackbar(supTitle: 'Please select transfer date', title: "Error");
                            }

                            // missNote(context,id,missPunchNote);
                          }
                        },
                      );
              }),
              SizedBox(
                height: 30,
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

  rotasTransfer(BuildContext buildContext, String currentDate, String transferDate, String reason) async {
    startLoadingRequestShift();
    try {
      var response = await RotasApi.shiftSwapRequest(
        authToken: sharePref.getString(authToken) ?? '',
        userId: sharePref.getString(userId) ?? '',
        currentDate: currentDate,
        transferDate: transferDate,
        reason: reason,
      );
      RotasTransfer rotasTransfer = RotasTransfer.fromJson(json.decode(response.data));

      print("Response Employee Rotas Transfer => : $response");

      if (response.statusCode == 200) {
        if (rotasTransfer.success == true) {
          stopLoadingRequestShift();
          Navigator.of(buildContext).pop();
          Navigator.of(buildContext).pop();
          GetSnackbar(supTitle: rotasTransfer.message.toString(), title: "Success");
        } else {
          stopLoadingRequestShift();
          GetSnackbar(supTitle: rotasTransfer.message.toString(), title: "Error");
        }
      } else {
        stopLoadingRequestShift();
        GetSnackbar(supTitle: rotasTransfer.message.toString(), title: "Error");
      }
    } catch (e) {
      stopLoadingRequestShift();
      GetSnackbar(supTitle: '', title: "Oops! Something went wrong.");
    }
  }
}

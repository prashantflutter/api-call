import 'dart:convert';

import 'package:ehubt_finanace_expence/employee_screen/model/rotas/rotas.dart';
import 'package:ehubt_finanace_expence/services/rotas_services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';


import '../../components/get_snackbar.dart';
import '../../utils/constant/app_string.dart';
import '../../utils/sharPreferenceUtils.dart';

class WorkScheduleController extends GetxController {
  var sharePref = SharedPrefs.instance;
  bool loading = false;

  var weekStartDate = '';
  var weekEndDate = '';
  var totalWeekHour = '0.0';
  List<RotasData> rotasList = [];

  var employeeName;
  var employeeProfilePic;
  var designation;

  final List<Map<String, dynamic>> workingGraphList = [];

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

          workingGraphList.clear();

          rotasList.forEachIndexed((element, index) {
            print("Total Hour :${rotasList[index].totalTimeInHours != null ? rotasList[index].totalTimeInHours.toString() : 0}");
            final Map<String, dynamic> workGraph = {
              "date":
                  '${rotasList[index].date.toString().split('-').last}-${rotasList[index].date.toString().split('-')[1]}\n${rotasList[index].day.toString().substring(0, 3)}\n${rotasList[index].startTime != null ? rotasList[index].startTime : ''}\n${rotasList[index].endTime != null ? rotasList[index].endTime : ''}',
              "hour": rotasList[index].totalTimeInHours != null ? rotasList[index].totalTimeInHours.toDouble() : 0,
            };
            workingGraphList.add(workGraph);


          });



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

  @override
  void onClose() {
    rotasList.clear();
    super.onClose();
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
}

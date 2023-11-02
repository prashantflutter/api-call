import 'dart:convert';

import 'package:ehubt_finanace_expence/employee_screen/model/rotas/send_available_rotas.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:get/get.dart';

import '../../components/get_snackbar.dart';
import '../../employee_screen/model/rotas/rotas_availability.dart';
import '../../services/rotas_services.dart';
import '../../utils/constant/app_string.dart';
import '../../utils/sharPreferenceUtils.dart';

class WorkAvailabilityController extends GetxController {
  var sharePref = SharedPrefs.instance;
  bool loading = false;
  bool loadingSubmit = false;
  List<RotasAvailableData> rotasAvailabilityList = [];

  List<String> selectedItemValue = [];

  @override
  void onInit() {
    rotasAvailability();
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

  void startLoadingSubmit() {
    loadingSubmit = true;
    update();
  }

  void stopLoadingSubmit() {
    loadingSubmit = false;
    update();
  }

  rotasAvailability() async {
    startLoading();
    try {
      var response = await RotasApi.rotasAvailability(authToken: sharePref.getString(authToken) ?? '', userId: sharePref.getString(userId) ?? '');
      RotasAvailability rotasAvailability = RotasAvailability.fromJson(json.decode(response.data));

      print("Response ERotas => : $response");

      if (response.statusCode == 200) {
        if (rotasAvailability.success == true) {
          rotasAvailabilityList.clear();
          rotasAvailabilityList.addAll((rotasAvailability?.data)!.map((x) => RotasAvailableData.fromJson(x.toJson())).toList());
          update();
          stopLoading();
        } else {
          stopLoading();
          GetSnackbar(supTitle: rotasAvailability.message.toString(), title: "Error");
        }
      } else {
        stopLoading();
        GetSnackbar(supTitle: rotasAvailability.message.toString(), title: "Error");
      }
    } catch (e) {
      print("Error : ${e.toString()}");
      stopLoading();
      GetSnackbar(supTitle: '', title: "Oops! Something went wrong.");
    }
  }

  // updateStatus(int index, bool? value) {
  //   if (value == true) {
  //     rotasAvailabilityList[index].status = 1;
  //   } else {
  //     rotasAvailabilityList[index].status = 0;
  //   }
  //   update();
  // }

  submit(BuildContext context) async {
    startLoadingSubmit();
    try {
      var response = await RotasApi.sendRotasAvailableData(
        authToken: sharePref.getString(authToken) ?? '',
        userId: sharePref.getString(userId) ?? '',
        data: json.encode(rotasAvailabilityList),
      );
      SendAvailableRotas sendAvailableRotas = SendAvailableRotas.fromJson(json.decode(response.data));

      print("Response send Rotas => : $response");

      if (response.statusCode == 200) {
        if (sendAvailableRotas.success == true) {
          stopLoadingSubmit();
          Navigator.of(context).pop();
          GetSnackbar(supTitle: sendAvailableRotas.message.toString(), title: "Success");
        } else {
          stopLoadingSubmit();
          GetSnackbar(supTitle: sendAvailableRotas.message.toString(), title: "Error");
        }
      } else {
        stopLoadingSubmit();
        GetSnackbar(supTitle: sendAvailableRotas.message.toString(), title: "Error");
      }
    } catch (e) {
      stopLoadingSubmit();
      GetSnackbar(supTitle: '', title: "Oops! Something went wrong.");
    }
  }

  updateWorkStatus(String? value,int index) {
    print("Status  : $value");
    value == 'Whole Day' ? rotasAvailabilityList[index].status = "1" : value == 'Full Day' ? rotasAvailabilityList[index].status = "2" : value == 'Half Day' ? rotasAvailabilityList[index].status = "3" : value == 'Not Available' ? rotasAvailabilityList[index].status = "4" : rotasAvailabilityList[index].status = "0";
    // rotasAvailabilityList[index].status = value;
   update();
  }
}

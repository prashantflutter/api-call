import 'dart:convert';


import 'package:ehubt_finanace_expence/utils/sharPreferenceUtils.dart';
import 'package:get/get.dart';

import '../../components/get_snackbar.dart';
import '../../employee_screen/model/employee_training_models/manuals_training_model.dart';


import '../../services/employee_training.dart';
import '../../utils/constant/app_string.dart';

class TrainingManualsController extends GetxController {
  List<trainingData> manualsTrainingList = [];
  bool loading = false;

  @override
  void onInit() {
    print("this is oinit");
    trainingManuals();
    // manualsTrainingList = ['Courses', 'Training Manuals', 'Training Manuals', 'Company Policy'];
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

  trainingManuals() async {
    startLoading();
    var response = await EmployeeTrainingServices.trainingManuals(authToken: SharedPrefs.instance.getString(authToken) ?? '', userId: SharedPrefs.instance.getString(userId) ?? '');
    print("this is module");
    ManualsTrainingModel manualsTrainingModel = ManualsTrainingModel.fromJson(
      jsonDecode(response.data),
    );
    print("Response Training Manual => : $response");
    try {
      if (response.statusCode == 200) {
        stopLoading();
        print("Response Training Manual StatusCode => : ${response.statusCode}");
        if (manualsTrainingModel.success == true) {
          manualsTrainingList.clear();
          manualsTrainingList.addAll(
            (manualsTrainingModel?.data)!.map((x) => trainingData.fromJson(x.toJson())).toList(),
          );
          update();
          print("This is list::::${manualsTrainingList}");
          print("List of Lenghth:::::${manualsTrainingList.length}");
        }
      } else {
        print("Error");
        stopLoading();
        GetSnackbar(supTitle: manualsTrainingModel.message.toString(), title: "Error");
      }
    } catch (e) {
      print("Oops! Something went wrong.");
      stopLoading();
      GetSnackbar(supTitle: '', title: "Oops! Something went wrong.");
    }
  }
}
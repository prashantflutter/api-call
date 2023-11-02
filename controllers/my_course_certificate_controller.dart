import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';

import '../../employee_screen/model/employee_training_models/course_certificate_model.dart';
import '../../employee_screen/model/employee_training_models/my_course_list_model.dart';
import '../../services/attendance_services.dart';
import '../../services/employee_training.dart';
import '../../utils/constant/app_string.dart';
import '../../utils/sharPreferenceUtils.dart';
import 'package:http/http.dart' as http;

class MyCourseCertificateController extends GetxController {
  var sharePref = SharedPrefs.instance;
  bool loading = false;
  List<Certificates> certificatesDataList = [];

  List<Courses> myAllCourseList = [];

  String remotePDF_path = "";
  var pathStore;

  @override
  void onInit() {
    super.onInit();
    // myCourseCertificate();

    myCourseList();
  }

  void startLoading() {
    loading = true;
    update();
  }

  void stopLoading() {
    loading = false;
    update();
  }

  myCourseCertificate() async {
    startLoading();
    try {
      var response = await EmployeeTrainingServices.getMyCourseCertificate(user_id: sharePref.getString(userId) ?? '');
      print("Response myCourseCertificate Report : ${response.toString()}");
      MyCourseCertificateModel myCourseCertificateModel = MyCourseCertificateModel.fromJson(response.data);

      if (response.statusCode == 200) {
        if (myCourseCertificateModel.success == true) {
          stopLoading();
          print("Response myCourseCertificate Report : ${myCourseCertificateModel.toString()}");
          certificatesDataList.addAll((myCourseCertificateModel.data!.certificates)!.map((e) => Certificates.fromJson(e.toJson())).toList());
          print("Connect to Server Successful...");
          update();
        } else {
          stopLoading();
          print("Something went to wrong ?");
        }
      } else {
        stopLoading();
        print("Something went to wrong ???");
      }
    } catch (e) {
      stopLoading();
      print("error : $e");
    }
  }

  setLinkFromApiToDownloadPDF(String uri) async {
    remotePDF_path = "";
    Completer<File> completer = Completer();
    List<int> intList = [];
    var selectedLink = uri;
    print('selectedLink.text : ${selectedLink}');
    var url = Uri.parse(selectedLink);
    final filename = "course_certificate.pdf";
    var response = await http.get(url, headers: {
      "Accept": "*/*",
      'X-API-Key': '1234',
    });
    print('Response : $response');
    if (response.statusCode == 200) {
      print('Response bodyBytes: ${response.bodyBytes.buffer.asUint8List()}');
      print('Response statusCode: ${response.statusCode}');
      print('Response contentLength: ${response.contentLength}');
      print('Response isRedirect: ${response.isRedirect}');
      print('Response persistentConnection: ${response.persistentConnection}');
      print('Response reasonPhrase: ${response.reasonPhrase}');
      print('Response request: ${response.request}');
      intList = response.bodyBytes.cast<int>().toList();
    }
    Uint8List? bytes = Uint8List.fromList(intList);
    var dir = await getApplicationDocumentsDirectory();
    File file = File("${dir.path}/$filename");
    try {
      await file.writeAsBytes(bytes);
      completer.complete(file);
      remotePDF_path = file.path;
      update();
      print("Download files $remotePDF_path");
    } on FileSystemException catch (err) {}
    return completer.future;
  }

  myCourseList() async {
    startLoading();
    try {
      var response = await EmployeeTrainingServices.getMyCourse(userId: sharePref.getString(userId) ?? '');
      print("Response myCourse : ${response.toString()}");
      MyCourseListModel myCourseListModel = MyCourseListModel.fromJson(response.data);

      if (response.statusCode == 200) {
        if (myCourseListModel.success == true) {
          stopLoading();
          myAllCourseList.clear();
          myAllCourseList.addAll((myCourseListModel.data!.courses)!.map((e) => Courses.fromJson(e.toJson())).toList());

          update();
        } else {
          stopLoading();
        }
      } else {
        stopLoading();
      }
    } catch (e) {

      print("Error : $e");
      stopLoading();
    }
  }
}

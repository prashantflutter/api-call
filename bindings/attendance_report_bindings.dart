import 'package:get/get.dart';

import '../controllers/attendance_report_controller.dart';


class AttendanceReportBindings extends Bindings{
  @override
  void dependencies() {
    Get.put(AttendanceReportController());
  }
}
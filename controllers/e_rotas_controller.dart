import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../employee_screen/screens/employee_main_screen/e_rotas_screen/work_schedule_screen.dart';

class RotasController extends GetxController{
  List<DateTimeRange> data = [];

  @override
  void onInit() {
    super.onInit();

    data = [
      DateTimeRange(
        start: DateTime(2021, 2, 24, 23, 15),
        end: DateTime(2021, 2, 25, 7, 30),
      ),
      DateTimeRange(
        start: DateTime(2021, 2, 22, 1, 55),
        end: DateTime(2021, 2, 22, 9, 12),
      ),
      DateTimeRange(
        start: DateTime(2021, 2, 20, 0, 25),
        end: DateTime(2021, 2, 20, 7, 34),
      ),
      DateTimeRange(
        start: DateTime(2021, 2, 17, 21, 23),
        end: DateTime(2021, 2, 18, 4, 52),
      ),
      DateTimeRange(
        start: DateTime(2021, 2, 13, 6, 32),
        end: DateTime(2021, 2, 13, 13, 12),
      ),
      DateTimeRange(
        start: DateTime(2021, 2, 1, 9, 32),
        end: DateTime(2021, 2, 1, 15, 22),
      ),
      DateTimeRange(
        start: DateTime(2021, 1, 22, 12, 10),
        end: DateTime(2021, 1, 22, 16, 20),
      ),
    ];

    update();

  }
}
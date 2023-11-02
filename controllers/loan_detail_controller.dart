import 'package:get/get.dart';

class LoanDetailController extends GetxController{
  var loanOption;
  var loanAmount;
  var installmentTime;
  var startDate;
  var endDate;
  var interest;
  var totalAmount;

  @override
  void onInit() {
    loanOption = Get.arguments[0];
    loanAmount = Get.arguments[1];
    installmentTime= Get.arguments[2];
    startDate = Get.arguments[3];
    endDate = Get.arguments[4];
    interest = Get.arguments[5];

    totalAmount = loanAmount + (loanAmount * interest / 100);

    print("Total Amount : $totalAmount");
    update();
    super.onInit();
  }
}
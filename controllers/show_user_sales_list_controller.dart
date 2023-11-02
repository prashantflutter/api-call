import 'dart:convert';

import 'package:ehubt_finanace_expence/services/finance_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../components/get_snackbar.dart';
import '../../employee_screen/model/finance/salesStoreModel.dart';
import '../../employee_screen/model/finance/show_user_sales_list_model.dart';
import '../../utils/constant/app_color.dart';
import '../../utils/constant/app_string.dart';
import '../../utils/constant/text_style.dart';
import '../../utils/sharPreferenceUtils.dart';

class ShowUserSalesListController extends GetxController {
  bool loading = false;
  var sharePref = SharedPrefs.instance;
  List<ShowUserSalesListData> showUserSalesListData = [];

  var amountController = TextEditingController();
  var commissionPaidController = TextEditingController();
  var commissionTextClaimController = TextEditingController();
  var taxController = TextEditingController();
  var netAmountController = TextEditingController();
  var selectDateController = TextEditingController();
  var commentController = TextEditingController();

  final fromKey = GlobalKey<FormState>();

  List<String> numberOfInstallment = ['This Week', 'Last Week', 'This Month', 'Last Month'];
  var hintText = DateFormat('yyyy-MM-dd').format(DateTime.now());
  String installment = 'This Week';

  DropdownButton<String> getInstallment() {
    List<DropdownMenuItem<String>> dropDownItems = [];
    for (String installment in numberOfInstallment) {
      var item = DropdownMenuItem(
        value: installment,
        child: Text(
          installment,
          style: kTextStyle.copyWith(color: kTitleColor, fontSize: 16, fontWeight: FontWeight.w500),
        ),
      );
      dropDownItems.add(item);
    }
    return DropdownButton(
      items: dropDownItems,
      value: installment,
      onChanged: (value) {
        installment = value!;

        if (value == "This Week") {
          showUserSalesList('this_week');
        } else if (value == "Last Week") {
          showUserSalesList('last_week');
        } else if (value == "This Month") {
          showUserSalesList('this_month');
        } else if (value == "Last Month") {
          showUserSalesList('last_month');
        }
        update();
      },
    );
  }

  @override
  void onInit() {
    showUserSalesList('this_week');
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

  showUserSalesList(String date_range) async {
    startLoading();
    try {
      var response = await FinanceApi.getUserSalesListAdded(
          authToken: sharePref.getString(authToken) ?? '', userId: sharePref.getString(userId) ?? '', date_range: date_range);
      ShowUserSalesListModel showUserSalesListModel = ShowUserSalesListModel.fromJson(json.decode(response.data));
      if (response.statusCode == 200) {
        print('showUserSalesList Response : ${response.toString()}');
        if (showUserSalesListModel.success == true) {
          stopLoading();
          showUserSalesListData.clear();
          showUserSalesListData.addAll((showUserSalesListModel.data!).map((e) => ShowUserSalesListData.fromJson(e.toJson())).toList());
        } else {
          showUserSalesListData.clear();
          stopLoading();
          GetSnackbar(supTitle: showUserSalesListModel.message.toString(), title: "Error");
        }
      } else {
        showUserSalesListData.clear();
        stopLoading();
        GetSnackbar(supTitle: showUserSalesListModel.message.toString(), title: "Error");
      }
    } catch (e) {
      showUserSalesListData.clear();
      stopLoading();
      GetSnackbar(supTitle: '', title: "Oops! Something went wrong.");
      print('error : $e');
    }
  }

  selectDateEdit(BuildContext context) async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime.now());
    if (picked != null) selectDateController.text = DateFormat('yyyy-MM-dd').format(picked);

    update();
  }

  updateSales(
      {required BuildContext context,
      required String listId,
      required String salesId,
      required String selectDate,
      required String amount,
      required String commissionPaidAmount,
      required String commissionTextClaim,
      required String taxAmount,
      required String netAmount,
      required String comment,
      required String isTextINText,
      required String taxAmountOrPercentage,
      required String commission,
      required String commission_tax_claim_percentage,
      required String exclusiveInclusive}) {
    selectDateController.text = selectDate;
    amountController.text = amount;
    commissionPaidController.text = commissionPaidAmount;
    commissionTextClaimController.text = commissionTextClaim;
    taxController.text = taxAmount;
    netAmountController.text = netAmount;
    commentController.text = comment;
    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        useSafeArea: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
        ),
        builder: (context) {
          return Container(
            padding: MediaQuery.of(context).viewInsets,
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 25,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child:   Container(
                          child: Text(
                            "Edit Sales",
                            textAlign: TextAlign.start,
                            style: kTextStyle.copyWith(
                              color: kTitleColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        excludeFromSemantics: true,
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: kMainColor.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 20,
                          ),
                        ),
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                      )
                    ],
                  ),

                  SizedBox(
                    height: 20,
                  ),
                  Form(
                    key: fromKey,
                    child: Column(
                      children: [
                        GetBuilder<ShowUserSalesListController>(builder: (_) {
                          return AppTextField(
                            textFieldType: TextFieldType.NAME,
                            readOnly: true,
                            validator: (value) {
                              if (value.toString().length == 0) {
                                return 'This field is required';
                              } else {
                                return null;
                              }
                            },
                            onTap: () async {
                              selectDateEdit(context);
                            },
                            controller: selectDateController,
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                floatingLabelBehavior: FloatingLabelBehavior.always,
                                suffixIcon: Icon(
                                  Icons.date_range_rounded,
                                  color: kGreyTextColor,
                                ),
                                labelText: 'From Date',
                                hintText: hintText),
                          );
                        }),
                        SizedBox(
                          height: 20.0,
                        ),
                        GetBuilder<ShowUserSalesListController>(builder: (_) {
                          return AppTextField(
                            textFieldType: TextFieldType.NUMBER,
                            controller: amountController,
                            onChanged: (value) {
                              commission_Paid(isTextINText.toString(), commission.toInt(), commission_tax_claim_percentage.toString(),
                                  taxAmountOrPercentage, exclusiveInclusive);
                            },
                            validator: (value) {
                              if (value.toString().length == 0) {
                                return 'This field is required';
                              } else {
                                return null;
                              }
                            },
                            decoration: InputDecoration(
                              // labelText: 'Enter Amount',
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Enter Amount',
                                    style: kTextStyle,
                                  ),
                                  Text(
                                    " *",
                                    style: kTextStyle.copyWith(color: kRedColor),
                                  ),
                                ],
                              ),
                              labelStyle: kTextStyle,
                              hintText: '1000',
                              border: const OutlineInputBorder(),
                            ),
                          );
                        }),
                        SizedBox(
                          height: 20.0,
                        ),
                        GetBuilder<ShowUserSalesListController>(builder: (_) {
                          return AppTextField(
                            textFieldType: TextFieldType.NUMBER,
                            readOnly: true,
                            enabled: false,
                            controller: commissionPaidController,
                            onChanged: (value) {},
                            validator: (value) {
                              if (value.toString().length == 0) {
                                return 'This field is required';
                              } else {
                                return null;
                              }
                            },
                            decoration: InputDecoration(
                              labelText: 'Commission Paid',
                              labelStyle: kTextStyle,
                              hintText: '100',
                              border: const OutlineInputBorder(),
                            ),
                          );
                        }),
                        SizedBox(
                          height: 20.0,
                        ),
                        GetBuilder<ShowUserSalesListController>(builder: (_) {
                          return AppTextField(
                            textFieldType: TextFieldType.NUMBER,
                            readOnly: true,
                            enabled: false,
                            controller: commissionTextClaimController,
                            onChanged: (value) {},
                            validator: (value) {
                              if (value.toString().length == 0) {
                                return 'This field is required';
                              } else {
                                return null;
                              }
                            },
                            decoration: InputDecoration(
                              labelText: 'Commission Tax Claim',
                              labelStyle: kTextStyle,
                              hintText: '100',
                              border: const OutlineInputBorder(),
                            ),
                          );
                        }),
                        SizedBox(
                          height: 20.0,
                        ),
                        GetBuilder<ShowUserSalesListController>(builder: (_) {
                          return AppTextField(
                            textFieldType: TextFieldType.NUMBER,
                            readOnly: true,
                            enabled: false,
                            controller: taxController,
                            onChanged: (value) {},
                            validator: (value) {
                              if (value.toString().length == 0) {
                                return 'This field is required';
                              } else {
                                return null;
                              }
                            },
                            decoration: InputDecoration(
                              labelText: 'Tax Amount',
                              labelStyle: kTextStyle,
                              hintText: '100.0',
                              border: const OutlineInputBorder(),
                            ),
                          );
                        }),
                        SizedBox(
                          height: 20.0,
                        ),
                        GetBuilder<ShowUserSalesListController>(builder: (_) {
                          return AppTextField(
                            textFieldType: TextFieldType.NUMBER,
                            readOnly: true,
                            enabled: false,
                            controller: netAmountController,
                            onChanged: (value) {},
                            validator: (value) {
                              if (value.toString().length == 0) {
                                return 'This field is required';
                              } else {
                                return null;
                              }
                            },
                            decoration: InputDecoration(
                              labelText: 'Net Amount',
                              labelStyle: kTextStyle,
                              hintText: '100.0',
                              border: const OutlineInputBorder(),
                            ),
                          );
                        }),
                        SizedBox(
                          height: 20.0,
                        ),
                        GetBuilder<ShowUserSalesListController>(builder: (_) {
                          return AppTextField(
                            controller: commentController,
                            textFieldType: TextFieldType.MULTILINE,
                            validator: (value) {
                              if (value.toString().length == 0) {
                                return 'This field is required';
                              } else {
                                return null;
                              }
                            },
                            maxLines: 5,
                            decoration: InputDecoration(
                              // labelText: 'Comment',
                              label: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'Comment',
                                    style: kTextStyle,
                                  ),
                                  Text(
                                    " *",
                                    style: kTextStyle.copyWith(color: kRedColor),
                                  ),
                                ],
                              ),
                              labelStyle: kTextStyle,
                              hintText: 'Comment',
                              border: const OutlineInputBorder(),
                            ),
                          );
                        }),
                        SizedBox(
                          height: 30.0,
                        ),
                        GetBuilder<ShowUserSalesListController>(builder: (_) {
                          return loading
                              ? CircularProgressIndicator()
                              : SizedBox(
                                  height: 50,
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    child: const Text('Submit'),
                                    onPressed: () {
                                      if (fromKey.currentState!.validate()) {
                                        updateSalesStore(listId, context, salesId);
                                      }
                                    },
                                  ),
                                );
                        }),
                        SizedBox(
                          height: 50.0,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  commission_Paid(String tax_in, int commissionValue, String TaxClaimPercentage, String taxAmountOrPercentage, String exclusiveInclusive) {
    var commissionPaid = (int.parse(amountController.text.toString().isNotEmpty ? amountController.text.toString() : '0') * commissionValue) / 100;
    commissionPaidController.text = commissionPaid.toString();

    update();

    var commissionTextClaim = (double.parse(commissionPaidController.text.toString().isNotEmpty ? commissionPaidController.text.toString() : '0') *
            TaxClaimPercentage.toDouble()) /
        100;
    commissionTextClaimController.text = commissionTextClaim.toString();

    update();

    if (tax_in == "1") {
      if (exclusiveInclusive == 'inclusive') {
        var temp1 = (double.parse(amountController.text.toString().isNotEmpty ? amountController.text.toString() : '0') -
            ((double.parse(amountController.text.toString().isNotEmpty ? amountController.text.toString() : '0')) *
                100 /
                (taxAmountOrPercentage.toDouble() + 100)));
        print("Temp1:$temp1");
        taxController.text = temp1.toStringAsFixed(2);
      } else {
        var taxAmount = (double.parse(amountController.text.toString().isNotEmpty ? amountController.text.toString() : '0')) *
            taxAmountOrPercentage.toDouble() /
            100;
        taxController.text = taxAmount.toStringAsFixed(2);
      }
    } else {
      taxController.text = taxAmountOrPercentage.toString();
    }

    update();
    var tempVal = (double.parse(amountController.text.toString().isNotEmpty ? amountController.text.toString() : '0') -
        double.parse(commissionPaidController.text.toString().isNotEmpty ? commissionPaidController.text.toString() : '0'));
    var totalNetAmount = (tempVal - double.parse(taxController.text.toString().isNotEmpty ? taxController.text.toString() : '0'));

    netAmountController.text = totalNetAmount.toStringAsFixed(2);

    update();
  }

  updateSalesStore(String list_id, BuildContext context, String salesId) async {
    startLoading();
    try {
      var response = await FinanceApi.getSalesStoreList(
        userId: sharePref.getString(userId) ?? '',
        authToken: sharePref.getString(authToken) ?? '',
        sale_id: salesId,
        amount: amountController.text.toString().trim(),
        date: selectDateController.text.toString().trim(),
        comments: commentController.text.toString().trim(),
        sales_list_id: list_id,
      );
      print(' SalesStore Response : ${response.toString()}');
      StoreSalesModel storeSalesModel = StoreSalesModel.fromJson(json.decode(response.data));

      if (response.statusCode == 200) {
        if (storeSalesModel.success == true) {
          startLoading();

          amountController.clear();
          commissionPaidController.clear();
          commissionTextClaimController.clear();
          taxController.clear();
          netAmountController.clear();
          commentController.clear();

          GetSnackbar(supTitle: storeSalesModel.message.toString(), title: "Success");

          installment == "This Week"
              ? showUserSalesList('this_week')
              : installment == "Last Week"
                  ? showUserSalesList('last_week')
                  : installment == "This Month"
                      ? showUserSalesList('this_month')
                      : installment == "Last Month"
                          ? showUserSalesList('last_month')
                          : showUserSalesList('this_week');

          Navigator.of(context).pop(true);

          update();
        } else {
          startLoading();
          GetSnackbar(supTitle: storeSalesModel.message.toString(), title: "Error");
        }
      } else {
        startLoading();
        GetSnackbar(supTitle: storeSalesModel.message.toString(), title: "Error");
      }
    } catch (e) {
      print('error : $e');
      startLoading();
      GetSnackbar(supTitle: '', title: "Oops! Something went wrong.");
    }
  }
}

import 'dart:convert';
import 'dart:io';

// import 'package:aws3_bucket/aws3_bucket.dart';
// import 'package:aws3_bucket/iam_crediental.dart';
// import 'package:aws3_bucket/image_data.dart';
import 'package:ehubt_finanace_expence/services/finance_services.dart';
import 'package:ehubt_finanace_expence/utils/constant/app_color.dart';
import 'package:ehubt_finanace_expence/utils/constant/text_style.dart';
import 'package:extended_image/extended_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:nb_utils/nb_utils.dart';

import '../../aws_s3_upload.dart';
import '../../components/get_snackbar.dart';
import '../../dospace/dospace_bucket.dart';
import '../../dospace/dospace_spaces.dart';
import '../../employee_screen/model/finance/store_expense_model.dart';
import '../../employee_screen/model/finance/update_doc_list.dart';
import '../../employee_screen/model/finance/user_expense_model.dart';
import '../../utils/constant/app_assets.dart';
import '../../utils/constant/app_string.dart';
import '../../utils/sharPreferenceUtils.dart';

class ExpenseDetailController extends GetxController {
  bool loading = false;
  bool loadingExpense = false;
  var sharePref = SharedPrefs.instance;
  List<UserExpenseData> userExpenseList = [];

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
          getUserExpense('this_week');
        } else if (value == "Last Week") {
          getUserExpense('last_week');
        } else if (value == "This Month") {
          getUserExpense('this_month');
        } else if (value == "Last Month") {
          getUserExpense('last_month');
        }
        update();
      },
    );
  }

  var amountController = TextEditingController();
  var taxController = TextEditingController();
  var totalAmountController = TextEditingController();
  var selectDateController = TextEditingController();
  var commentController = TextEditingController();

  List<UpdateDocListModel> updateDocList = [];

  List<String> editUploadDocList = [];

  final fromKey = GlobalKey<FormState>();

  @override
  void onInit() {
    getUserExpense('this_week');
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

  void startLoadingExpense() {
    loadingExpense = true;
    update();
  }

  void stopLoadingExpense() {
    loadingExpense = false;
    update();
  }

  selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(2000), lastDate: DateTime.now());
    if (picked != null) selectDateController.text = DateFormat('yyyy-MM-dd').format(picked);

    update();
  }

  calculateTax(String isIncludingText) {
    if (isIncludingText == '1') {
      var tax = (int.parse(amountController.text.toString().isNotEmpty ? amountController.text.toString() : '0') *
              int.parse(taxController.text.toString().isNotEmpty ? taxController.text.toString() : '0')) /
          100;
      totalAmountController.text = (int.parse(amountController.text.toString()) + tax).toString();
      update();
    } else {
      var totalAmount = int.parse(amountController.text.toString().isNotEmpty ? amountController.text.toString() : '0') +
          int.parse(taxController.text.toString().isNotEmpty ? taxController.text.toString() : '0');
      totalAmountController.text = totalAmount.toString();
      update();
    }
  }

  getUserExpense(String filterType) async {
    startLoading();
    try {
      var response = await FinanceApi.getUSerExpense(
          authToken: sharePref.getString(authToken) ?? '', userId: sharePref.getString(userId) ?? '', filterType: filterType);
      UserExpenseModel userExpenseModel = UserExpenseModel.fromJson(json.decode(response.data));

      print("Response LeaveDetail => : $response");

      if (response.statusCode == 200) {
        if (userExpenseModel.success == true) {
          userExpenseList.clear();
          userExpenseList.addAll((userExpenseModel?.data)!.map((x) => UserExpenseData.fromJson(x.toJson())).toList());
          update();
          stopLoading();
        } else {
          userExpenseList.clear();
          stopLoading();
          GetSnackbar(supTitle: userExpenseModel.message.toString(), title: "Error");
        }
      } else {
        userExpenseList.clear();
        stopLoading();
        GetSnackbar(supTitle: userExpenseModel.message.toString(), title: "Error");
      }
    } catch (e) {
      print("Error : ${e.toString()}");
      userExpenseList.clear();
      stopLoading();
      GetSnackbar(supTitle: '', title: "Oops! Something went wrong.");
    }
  }

  void updateController({
    required BuildContext context,
    required String expenseListID,
    required String amount,
    required String taxAmount,
    required String totalAmount,
    required String selectDate,
    required String comment,
    required String expenseId,
    required List<ExpenseDocuments> docList,
    required String isIncludingText,
    required String updateDateRange,
  }) {
    amountController.text = amount;
    taxController.text = taxAmount;
    selectDateController.text = selectDate;
    totalAmountController.text = totalAmount;
    commentController.text = comment;
    updateDocList.clear();
    update();

    for (int i = 0; i < 5; i++) {
      if (docList.length - 1 >= i) {
        print("Document List : ${docList[i].document.toString().trim()}");
        if (docList[i].document.toString().trim() != "") {
          updateDocList.add(UpdateDocListModel(docPath: docList[i].document.toString().trim(), isEdit: false));
        }
      } else {
        updateDocList.add(UpdateDocListModel(docPath: '', isEdit: false));
      }
    }

    print("Update Doc List : ${updateDocList.length}");

    update();
    editExpenseDetail(
        context: context, expenseId: expenseId, isIncludingText: isIncludingText, expenseListID: expenseListID, updateDateRange: updateDateRange);
  }

  editExpenseDetail(
      {required BuildContext context,
      required String expenseId,
      required String isIncludingText,
      required String expenseListID,
      required String updateDateRange}) {
    var controller = Get.find<ExpenseDetailController>();

    return Get.bottomSheet(
      GetBuilder<ExpenseDetailController>(
          init: controller,
          builder: (controller) {
            return SafeArea(
              child: Container(
                padding: MediaQuery.of(context).viewInsets,
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              child: Text(
                                "Edit Expense",
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
                            GetBuilder<ExpenseDetailController>(builder: (_) {
                              return AppTextField(
                                textFieldType: TextFieldType.NUMBER,
                                controller: amountController,
                                onChanged: (value) {
                                  calculateTax(isIncludingText);
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
                            GetBuilder<ExpenseDetailController>(builder: (_) {
                              return AppTextField(
                                textFieldType: TextFieldType.NUMBER,
                                controller: taxController,
                                enabled: false,
                                onChanged: (value) {
                                  print("Change Value : $value");
                                  if (value.length > 0) {
                                    calculateTax(isIncludingText);
                                  }
                                },
                                validator: (value) {
                                  if (value.toString().length == 0) {
                                    return 'This field is required';
                                  } else {
                                    return null;
                                  }
                                },
                                decoration: InputDecoration(
                                  labelText: '${isIncludingText == '1' ? 'tax(%)' : 'Tax Amount'}',
                                  labelStyle: kTextStyle,
                                  hintText: '${isIncludingText == '1' ? '5%' : '100'}',
                                  border: const OutlineInputBorder(),
                                ),
                              );
                            }),
                            const SizedBox(
                              height: 20.0,
                            ),
                            AppTextField(
                              textFieldType: TextFieldType.NAME,
                              controller: totalAmountController,
                              enabled: false,
                              validator: (value) {
                                if (value.toString().length == 0) {
                                  return 'This field is required';
                                } else {
                                  return null;
                                }
                              },
                              decoration: InputDecoration(
                                labelText: 'Total Amount',
                                labelStyle: kTextStyle,
                                hintText: '0',
                                border: const OutlineInputBorder(),
                              ),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            GetBuilder<ExpenseDetailController>(builder: (_) {
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
                                  selectDate(context);
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
                            const SizedBox(
                              height: 20.0,
                            ),
                            GetBuilder<ExpenseDetailController>(builder: (_) {
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
                              height: 20.0,
                            ),
                            Container(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Upload Image(Max 5)",
                                textAlign: TextAlign.start,
                                style: kTextStyle.copyWith(
                                  color: kTitleColor,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 10.0,
                            ),
                            GridView.builder(
                              itemCount: updateDocList.length,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                                maxCrossAxisExtent: 130.0,
                                crossAxisSpacing: 20.0,
                                mainAxisSpacing: 20.0,
                              ),
                              itemBuilder: (context, i) => Card(
                                child: Stack(
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  children: [
                                    updateDocList[i].docPath != ''
                                        ? updateDocList[i].isEdit == true
                                            ? updateDocList[i].docPath.toString().split(".").last == 'png'
                                                ? Positioned.fill(
                                                    child: Image.file(
                                                    File(updateDocList[i].docPath!),
                                                    fit: BoxFit.cover,
                                                  ))
                                                : updateDocList[i].docPath.toString().split(".").last == 'jpg'
                                                    ? Positioned.fill(
                                                        child: Image.file(
                                                          File(updateDocList[i].docPath!),
                                                          fit: BoxFit.cover,
                                                        ),
                                                      )
                                                    : updateDocList[i].docPath.toString().split(".").last == 'jpeg'
                                                        ? Positioned.fill(
                                                            child: Image.file(
                                                            File(updateDocList[i].docPath!),
                                                            fit: BoxFit.cover,
                                                          ))
                                                        : updateDocList[i].docPath.toString().split(".").last == 'pdf'
                                                            ? Container(
                                                                alignment: Alignment.center,
                                                                padding: const EdgeInsets.all(10),
                                                                child: SvgPicture.asset(
                                                                  pdf,
                                                                  height: 70,
                                                                ),
                                                              )
                                                            : updateDocList[i].docPath.toString().split(".").last == 'doc'
                                                                ? Container(
                                                                    alignment: Alignment.center,
                                                                    padding: const EdgeInsets.all(10),
                                                                    child: SvgPicture.asset(
                                                                      doc,
                                                                      height: 70,
                                                                    ),
                                                                  )
                                                                : updateDocList[i].docPath.toString().split(".").last == 'docx'
                                                                    ? Container(
                                                                        alignment: Alignment.center,
                                                                        padding: const EdgeInsets.all(10),
                                                                        child: SvgPicture.asset(
                                                                          doc,
                                                                          height: 70,
                                                                        ),
                                                                      )
                                                                    : updateDocList[i].docPath.toString().split(".").last == "xlsx"
                                                                        ? Container(
                                                                            alignment: Alignment.center,
                                                                            padding: const EdgeInsets.all(10),
                                                                            child: SvgPicture.asset(
                                                                              xls,
                                                                              height: 70,
                                                                            ),
                                                                          )
                                                                        : updateDocList[i].docPath.toString().split(".").last == "xls"
                                                                            ? Container(
                                                                                alignment: Alignment.center,
                                                                                padding: const EdgeInsets.all(10),
                                                                                child: SvgPicture.asset(
                                                                                  xls,
                                                                                  height: 70,
                                                                                ),
                                                                              )
                                                                            : Padding(
                                                                                padding: const EdgeInsets.all(10),
                                                                                child: Icon(
                                                                                  Icons.add,
                                                                                  color: Colors.blue,
                                                                                  size: 30,
                                                                                ),
                                                                              )
                                            : Container(
                                                margin: EdgeInsets.symmetric(horizontal: 10),
                                                color: Colors.transparent,
                                                child: updateDocList[i].docPath!.split(".").last == "pdf"
                                                    ? Container(
                                                        alignment: Alignment.center,
                                                        padding: const EdgeInsets.all(10),
                                                        child: SvgPicture.asset(
                                                          pdf,
                                                          height: 70,
                                                        ),
                                                      )
                                                    : updateDocList[i].docPath!.split(".").last == "doc"
                                                        ? Container(
                                                            alignment: Alignment.center,
                                                            padding: const EdgeInsets.all(10),
                                                            child: SvgPicture.asset(
                                                              doc,
                                                              height: 70,
                                                            ),
                                                          )
                                                        : updateDocList[i].docPath!.split(".").last == "docx"
                                                            ? Container(
                                                                alignment: Alignment.center,
                                                                padding: const EdgeInsets.all(10),
                                                                child: SvgPicture.asset(
                                                                  doc,
                                                                  height: 70,
                                                                ),
                                                              )
                                                            : updateDocList[i].docPath!.split(".").last == "xlsx"
                                                                ? Container(
                                                                    alignment: Alignment.center,
                                                                    padding: const EdgeInsets.all(10),
                                                                    child: SvgPicture.asset(
                                                                      xls,
                                                                      height: 70,
                                                                    ),
                                                                  )
                                                                : updateDocList[i].docPath!.split(".").last == "xls"
                                                                    ? Container(
                                                                        alignment: Alignment.center,
                                                                        padding: const EdgeInsets.all(10),
                                                                        child: SvgPicture.asset(
                                                                          xls,
                                                                          height: 70,
                                                                        ),
                                                                      )
                                                                    : ExtendedImage.network(
                                                                        updateDocList[i].docPath!.trim(),
                                                                        cache: false,
                                                                        fit: BoxFit.fill,
                                                                        shape: BoxShape.rectangle,
                                                                        borderRadius: BorderRadius.all(Radius.circular(2.0)),
                                                                        //cancelToken: cancellationToken,
                                                                      ),
                                              )
                                        : Container(
                                            alignment: Alignment.center,
                                            child: TextButton(
                                              style: TextButton.styleFrom(
                                                backgroundColor: Colors.blue.withOpacity(0.2),
                                                shape: CircleBorder(),
                                              ),
                                              child: Padding(
                                                padding: const EdgeInsets.all(10),
                                                child: Icon(
                                                  Icons.add,
                                                  color: Colors.blue,
                                                  size: 30,
                                                ),
                                              ),
                                              onPressed: () async {
                                                FilePickerResult? result = await FilePicker.platform.pickFiles(
                                                  type: FileType.custom,
                                                  allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx', 'xlsx', 'xls'],
                                                );
                                                PlatformFile file = result!.files.first;
                                                print("Result : ${file.path}");

                                                updateDocList[i].docPath = file.path;
                                                updateDocList[i].isEdit = true;

                                                update();
                                              },
                                            ),
                                          ),
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: updateDocList[i].docPath != ''
                                          ? /*InkWell(
                                            excludeFromSemantics: true,
                                            onLongPress: () {},
                                            child: Container(
                                                margin: const EdgeInsets.all(4),
                                                padding: const EdgeInsets.all(3),
                                                decoration: BoxDecoration(
                                                  color: Colors.white.withOpacity(0.2),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: const Icon(
                                                  Icons.close,
                                                  size: 20,
                                                )),
                                            onTap: () {
                                              removeDecItem(i);
                                            },
                                          )*/
                                          Column(
                                              children: [
                                                InkWell(
                                                  onTap: () async {
                                                    FilePickerResult? result = await FilePicker.platform.pickFiles(
                                                      type: FileType.custom,
                                                      allowedExtensions: ['jpg', 'jpeg', 'png', 'pdf', 'doc', 'docx', 'xlsx', 'xls'],
                                                    );
                                                    PlatformFile file = result!.files.first;
                                                    print("Result : ${file.path}");
                                                    updateDocList[i].docPath = file.path;
                                                    updateDocList[i].isEdit = true;
                                                    update();
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets.all(4.0),
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(8.0),
                                                      color: kMainColor.withOpacity(0.1),
                                                    ),
                                                    child: const Icon(
                                                      Icons.edit,
                                                      color: kMainColor,
                                                    ),
                                                  ),
                                                ),
                                                SizedBox(
                                                  height: 2,
                                                ),
                                                InkWell(
                                                  onTap: () async {
                                                    confirmDelete(context, i);
                                                  },
                                                  child: Container(
                                                    padding: const EdgeInsets.all(4.0),
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(8.0),
                                                      color: kMainColor.withOpacity(0.1),
                                                    ),
                                                    child: const Icon(
                                                      Icons.delete,
                                                      color: kRedColor,
                                                    ),
                                                  ),
                                                )
                                              ],
                                            )
                                          : Container(),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(
                              height: 20.0,
                            ),
                            GetBuilder<ExpenseDetailController>(builder: (_) {
                              return loadingExpense
                                  ? SizedBox(
                                      height: 30,
                                      width: 30,
                                      child: CircularProgressIndicator(),
                                    )
                                  : SizedBox(
                                      height: 50,
                                      width: double.infinity,
                                      child: ElevatedButton(
                                        child: const Text('Update'),
                                        onPressed: () {
                                          if (fromKey.currentState!.validate()) {
                                            editExpense(context, expenseId, expenseListID, updateDateRange);
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
              ),
            );
          }),
      isDismissible: true,
      barrierColor: Colors.transparent,
      backgroundColor: Colors.white,
      enableDrag: true,
      ignoreSafeArea: false,
      isScrollControlled: true,
    );
  }

  removeDecItem(int i) {
    updateDocList[i].docPath = '';
    updateDocList[i].isEdit = true;
    update();
  }

  editExpense(BuildContext context, String expenseId, String expenseListID, String updateDateRange) async {
    startLoadingExpense();

    try {
      if (sharePref.getString('uploadOrNot') == '1') {
        var regionName = sharePref.getString('docRegionNameEmployee') ?? '';
        var bucketName = sharePref.getString('docBucketNameEmployee') ?? '';
        var accessKey = sharePref.getString('docAccessKeyEmployee') ?? '';
        var secretKey = sharePref.getString('docSecretKeyEmployee') ?? '';



        editUploadDocList.clear();

        if (sharePref.getString('uploadServerName') == 'aws') {
          for (int i = 0; i < updateDocList.length; i++) {
            if (updateDocList[i].isEdit == true && updateDocList[i].docPath != '') {
              var fileName = DateTime.now().millisecondsSinceEpoch.toString() + ".${updateDocList[i].docPath!.split('.').last.replaceAll(" ", "")}";
              AwsS3.uploadFile(
                  accessKey: accessKey,
                  secretKey: secretKey,
                  file: File(updateDocList[i].docPath!),
                  bucket: bucketName,
                  region: regionName,
                  filename: fileName
                // optional
              );
              editUploadDocList.add("https://$bucketName.s3.$regionName.amazonaws.com/$fileName");

            } else {
              if (updateDocList[i].docPath != '') {
                editUploadDocList.add(updateDocList[i].docPath!);
              }
            }
          }
          stopLoadingExpense();
        } else {
          for (int i = 0; i < updateDocList.length; i++) {
            if (updateDocList[i].isEdit == true && updateDocList[i].docPath != '') {
              Spaces spaces = new Spaces(
                region: '$regionName',
                accessKey: '$accessKey', //In Backend Filed Name is Digital Ocean - Access Key
                secretKey: '$secretKey', //In Backend Filed Name is Digital Ocean - Secret Key
              );

              String file_name = DateTime.now().millisecondsSinceEpoch.toString() + ".${updateDocList[i].docPath!.split('.').last.replaceAll(" ", "")}";
              var response = await spaces.bucket('$bucketName').uploadFile(file_name, File(updateDocList[i].docPath!), '*/*', Permissions.public);
              print("File Name: ${file_name}");
              editUploadDocList.add("https://$bucketName.$regionName.cdn.digitaloceanspaces.com/${file_name}");
              await spaces.close();
            } else {
              if (updateDocList[i].docPath != '') {
                editUploadDocList.add(updateDocList[i].docPath!);
              }
            }
          }
          stopLoadingExpense();
        }
      }
    } catch (error) {
      print("Error : $error");
      stopLoadingExpense();
    }

    print("Image List : $editUploadDocList");
    var uploadListDoc = editUploadDocList.join(', ');

    update();
    print("Image List : $uploadListDoc");

    startLoadingExpense();

    try {
      var response = await FinanceApi.storeExpense(
        authToken: sharePref.getString(authToken) ?? '',
        userId: sharePref.getString(userId) ?? '',
        amount: amountController.text.toString().trim(),
        expenseId: expenseId,
        taxAmount: taxController.text.toString().trim(),
        totalAmount: totalAmountController.text.toString().trim(),
        selectDate: selectDateController.text.toString().trim(),
        comment: commentController.text.toString().trim(),
        expenseListID: expenseListID,
        imageList: uploadListDoc,
      );
      StoreExpenseModel storeExpenseModel = StoreExpenseModel.fromJson(json.decode(response.data));

      print("Response ExpenseList => : $response");

      if (response.statusCode == 200) {
        if (storeExpenseModel.success == true) {
          stopLoadingExpense();
          GetSnackbar(supTitle: storeExpenseModel.message.toString(), title: "Success");
          amountController.clear();
          taxController.clear();
          totalAmountController.clear();
          selectDateController.clear();
          commentController.clear();
          // Navigator.of(context).pop();
          updateDateRange == "This Week"
              ? getUserExpense('this_week')
              : updateDateRange == "Last Week"
                  ? getUserExpense('last_week')
                  : updateDateRange == "This Month"
                      ? getUserExpense('this_month')
                      : updateDateRange == "Last Month"
                          ? getUserExpense('last_month')
                          : getUserExpense('this_week');
          Navigator.of(context).pop();
          update();
        } else {
          stopLoadingExpense();
          GetSnackbar(supTitle: storeExpenseModel.message.toString(), title: "Error");
        }
      } else {
        stopLoadingExpense();
        GetSnackbar(supTitle: storeExpenseModel.message.toString(), title: "Error");
      }
    } catch (e) {
      print("Error : ${e.toString()}");
      stopLoadingExpense();
      GetSnackbar(supTitle: '', title: "Oops! Something went wrong.");
    }
  }

  confirmDelete(BuildContext context, int index) {
    showDialog(
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Text('Alert'),
            content: Text('Are you sure want to delete?'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  updateDocList[index].docPath = '';
                  updateDocList[index].isEdit = false;
                  update();
                },
                child: Text('Yes'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context); //close Dialog
                },
                child: Text('cancel'),
              )
            ],
          );
        });
  }

  @override
  void dispose() {
    Get.delete<ExpenseDetailController>();
    super.dispose();
  }
}

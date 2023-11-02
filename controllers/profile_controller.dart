import 'dart:convert';
import 'dart:io';

import 'package:ehubt_finanace_expence/utils/constant/app_assets.dart';
import 'package:ehubt_finanace_expence/utils/constant/text_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../components/get_snackbar.dart';
import '../../employee_screen/model/edit_profile/edit_profile.dart';
import '../../employee_screen/model/employee_profile/employee_profile.dart';
import '../../services/auth_api.dart';
import '../../utils/constant/app_color.dart';
import '../../utils/constant/app_string.dart';
import '../../utils/sharPreferenceUtils.dart';

class ProfileController extends GetxController {
  bool loading = false;
  List<String> genderList = ['Male', 'Female', 'Non-binary'];
  var gender;
  var sharePref = SharedPrefs.instance;

  var nameController = TextEditingController();
  var emailController = TextEditingController();
  var mobileController = TextEditingController();
  var addressController = TextEditingController();

  DropdownButton<String> getGender() {
    List<DropdownMenuItem<String>> dropDownItems = [];
    for (String gender in genderList) {
      var item = DropdownMenuItem(
        value: gender,
        child: Text(
          gender,
          style: kTextStyle.copyWith(color: kTitleColor),
        ),
      );
      dropDownItems.add(item);
    }
    return DropdownButton(
      items: dropDownItems,
      value: gender,
      onChanged: (value) {
        gender = value!;
        update();
      },
    );
  }

  final picker = ImagePicker();
  File selectImage = File("");

  var profilePic;
  var firstName = '';
  var lastName = '';
  var designation = '';
  var email = '';
  var mobile = '';
  var address = '';

  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
    getProfile();
  }

  void startLoading() {
    loading = true;
    update();
  }

  void stopLoading() {
    loading = false;
    update();
  }

  getProfile() async {
    startLoading();
    try {
      var response = await AuthApi.employeeProfile(authToken: sharePref.getString(authToken) ?? '', userId: sharePref.getString(userId) ?? '');
      EmployeeProfile employeeProfile = EmployeeProfile.fromJson(json.decode(response.data));

      print("Response Employee Profile => : $response");

      if (response.statusCode == 200) {
        stopLoading();

        if (employeeProfile.success == true) {
          profilePic = employeeProfile.data!.userImage;
          firstName = employeeProfile.data!.firstName.toString();
          lastName = employeeProfile.data!.lastName.toString();
          email = employeeProfile.data!.email.toString();
          mobile = employeeProfile.data!.mobile.toString();
          address = employeeProfile.data!.address.toString();
          gender = employeeProfile.data!.gender;

          nameController.text = '${firstName} ${lastName}';
          emailController.text = email;
          mobileController.text = mobile;
          addressController.text = address;

          sharePref.setString(userName, '$firstName $lastName');
          sharePref.setString(profilePicture, '${employeeProfile.data!.userImage}');
          sharePref.setString('designation', '${employeeProfile.data!.designationName}');

          ///Bucket Detail
          sharePref.setString('uploadServerName', '${employeeProfile.data!.serverName}');
          sharePref.setString('uploadOrNot', '${employeeProfile.data!.uploading}');
          sharePref.setString('regionName', '${employeeProfile.data!.region}');
          sharePref.setString('bucketName', '${employeeProfile.data!.bucketName}');
          sharePref.setString('accessKey', '${employeeProfile.data!.accessKey}');
          sharePref.setString('secretKey', '${employeeProfile.data!.secretKey}');

          ///Sales and Expense Check Enable Or Not
          sharePref.setString('isExpenseAdd', '${employeeProfile.data!.expense ?? '0'}');
          sharePref.setString('isSalesAdd', '${employeeProfile.data!.sales ?? '0'}');

          sharePref.setString('EmployeeChatUrl', '${employeeProfile.data!.chatUrl}');
          update();
        }
      } else {
        stopLoading();
        GetSnackbar(supTitle: employeeProfile.message.toString(), title: "Error");
      }
    } catch (e) {
      stopLoading();
      GetSnackbar(supTitle: '', title: "Oops! Something went wrong.");
    }
  }

  /* selectImageDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black87.withOpacity(0.80),
      barrierDismissible: false,
      barrierLabel: 'Dialog',
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 100),
              padding: EdgeInsets.symmetric(vertical: 30),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(15.0), color: kWhiteColor),
              child: Row(
                children: [
                  Expanded(
                    child: Material(
                      child: InkWell(
                        onTap: () {
                          selectOrTakePhoto(ImageSource.camera);
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          child: Column(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(width: 1, color: kMainColor),
                                  shape: BoxShape.circle,
                                  color: kMainColor,
                                ),
                                padding: EdgeInsets.all(20),
                                child: SvgPicture.asset(
                                  camera,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Camera",
                                style: kTextStyle.copyWith(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                  decoration: TextDecoration.none,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 100,
                    width: 5,
                    child: VerticalDivider(
                      color: Colors.black87,
                      thickness: 2,
                    ),
                  ),

                  //
                  Expanded(
                    child: Material(
                      child: InkWell(
                        onTap: () {
                          selectOrTakePhoto(ImageSource.gallery);
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          child: Column(
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  border: Border.all(width: 1, color: kMainColor),
                                  shape: BoxShape.circle,
                                  color: kMainColor,
                                ),
                                padding: EdgeInsets.all(20),
                                child: SvgPicture.asset(
                                  gallery,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Gallery",
                                style: kTextStyle.copyWith(
                                    fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black87, decoration: TextDecoration.none),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 100, vertical: 10),
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(horizontal: 60, vertical: 20),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(15.0), color: kWhiteColor),
                  child: Text(
                    "Cancel",
                    textAlign: TextAlign.center,
                    style: kTextStyle.copyWith(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.black, decoration: TextDecoration.none),
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }*/
  selectImageDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black87.withOpacity(0.80),
      barrierDismissible: false,
      barrierLabel: 'Dialog',
      transitionDuration: Duration(milliseconds: 400),
      pageBuilder: (_, __, ___) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20),
              padding: EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(15.0), color: kWhiteColor),
              child: Row(
                children: [
                  Expanded(
                    child: Material(
                      child: InkWell(
                        onTap: () {
                          selectOrTakePhoto(ImageSource.camera);
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          child: Column(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  border: Border.all(width: 1, color: kMainColor),
                                  shape: BoxShape.circle,
                                  color: kMainColor,
                                ),
                                padding: EdgeInsets.all(10),
                                child: SvgPicture.asset(
                                  camera,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Camera",
                                style: kTextStyle.copyWith(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                  decoration: TextDecoration.none,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Container(
                    height: 50,
                    width: 5,
                    child: VerticalDivider(
                      color: Colors.black87,
                      thickness: 2,
                    ),
                  ),

                  //
                  Expanded(
                    child: Material(
                      child: InkWell(
                        onTap: () {
                          selectOrTakePhoto(ImageSource.gallery);
                          Navigator.of(context).pop();
                        },
                        child: Container(
                          child: Column(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  border: Border.all(width: 1, color: kMainColor),
                                  shape: BoxShape.circle,
                                  color: kMainColor,
                                ),
                                padding: EdgeInsets.all(10),
                                child: SvgPicture.asset(
                                  gallery,
                                ),
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              Text(
                                "Gallery",
                                style: kTextStyle.copyWith(
                                    fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87, decoration: TextDecoration.none),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  width: MediaQuery.of(context).size.width,
                  padding: EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(15.0), color: kWhiteColor),
                  child: Text(
                    "Cancel",
                    textAlign: TextAlign.center,
                    style: kTextStyle.copyWith(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black, decoration: TextDecoration.none),
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }

  selectOrTakePhoto(ImageSource imageSource) async {
    final pickedFile = await picker.pickImage(source: imageSource, imageQuality: 20);

    if (pickedFile != null) {
      selectImage = File(pickedFile.path);

      print("Select Image Path : $selectImage");
      update();
    } else {
      print('No photo was selected or taken');
    }

    update();
  }

  editProfile(String fullName, String email, String address, String gender, File image, BuildContext context) async {
    startLoading();
    try {
      var response = await AuthApi.editProfile(
        authToken: sharePref.getString(authToken) ?? '',
        userId: sharePref.getString(userId) ?? '',
        fullName: fullName,
        email: email,
        address: address,
        gender: gender,
        image: selectImage,
      );

      EditProfilemodel editProfilemodel = EditProfilemodel.fromJson(
        jsonDecode(response.data),
      );
      if (response.statusCode == 200) {
        print("this is response code");
        print("this is response stuste code:::::${response.statusCode}");
        if (editProfilemodel.success == true) {
          stopLoading();
          print("this is :::::${profilePic}");
          GetSnackbar(supTitle: 'Profile Update Successfully...', title: "Success");
          getProfile();
          Navigator.of(context).pop();
        } else {
          stopLoading();
          print('Something went to Wrong ??');
          GetSnackbar(supTitle: 'Leave already Update!', title: "Error");
        }
      } else {
        stopLoading();
        GetSnackbar(supTitle: 'Something went to Wrong ?', title: "Error");
        print('Something went to Wrong ????');
      }
    } catch (e) {
      stopLoading();
      print('Error $e');
      GetSnackbar(supTitle: 'Something went to Wrong ?', title: "Error");
    }
  }
}

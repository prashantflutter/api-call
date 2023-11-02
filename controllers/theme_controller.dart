import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/constant/app_string.dart';
import '../../utils/sharPreferenceUtils.dart';

class ThemeController{
  bool getThemeDataFromBox() {
    return SharedPrefs.instance.getBool(isDarkModes) ?? false;
  }

  ThemeMode get themeDataGet => getThemeDataFromBox() ? ThemeMode.dark : ThemeMode.light;

  void changesTheme() {
    Get.changeThemeMode(getThemeDataFromBox() ? ThemeMode.dark : ThemeMode.light);
    saveThemeDataInBox(!getThemeDataFromBox());
  }

  saveThemeDataInBox(bool isDark) {
    SharedPrefs.instance.setBool(isDarkModes, isDark);
  }
}
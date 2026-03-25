import 'package:flutter/material.dart';
import 'package:flutter_template/modules/dashboard/bookmark/presentation/bookmark_screen.dart';
import 'package:flutter_template/modules/dashboard/calender/presentation/calender_screen.dart';
import 'package:flutter_template/modules/dashboard/home/presentation/home_screen.dart';
import 'package:flutter_template/modules/dashboard/profile/presentation/profile_screen.dart';
import 'package:flutter_template/widget/app_snackbar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

import '../../../../utils/app_preferences.dart';
import '../../profile/controller/profile_setting_controller.dart';

class DashBoardController extends GetxController {
  RxInt currentIndex = 0.obs;

  void onPageChanged(int index) async {
    currentIndex.value = index;
    update();
  }

  DateTime? currentBackPressTime;

  Future<bool> onWillPop() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null || now.difference(currentBackPressTime!) > const Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: "Tap back again to leave");
      AppSnackBar();
      return Future.value(false);
    }
    return Future.value(true);
  }

  List<Widget> screen = [
    HomeScreen(),
    CalenderScreen(),
    BookMarkScreen(),
    ProfileScreen(),
  ];

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }
}

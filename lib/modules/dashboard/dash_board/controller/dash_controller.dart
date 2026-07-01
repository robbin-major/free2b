import 'package:flutter/material.dart';
import 'package:flutter_template/modules/dashboard/bookmark/presentation/bookmark_screen.dart';
import 'package:flutter_template/modules/dashboard/calender/presentation/calender_screen.dart';
import 'package:flutter_template/modules/dashboard/home/presentation/home_screen.dart';
import 'package:flutter_template/modules/dashboard/profile/presentation/profile_screen.dart';
import 'package:flutter_template/utils/auth_session_service.dart';
import 'package:flutter_template/widget/app_snackbar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';

class DashBoardController extends GetxController {
  RxInt currentIndex = 0.obs;

  bool canOpenIndex(int index) {
    return index != 2 && index != 3 || AuthSessionService.isSignedIn;
  }

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

  // Future tab idea: replacing Bookmarks with Map should show today's
  // Chicago events first. Friend/people-attending signals should be opt-in,
  // privacy-preserving, and backed by moderation before public rollout.
  List<Widget> screen = [
    HomeScreen(),
    CalenderScreen(),
    BookMarkScreen(),
    ProfileScreen(),
  ];

  @override
  void onInit() {
    final Object? arguments = Get.arguments;
    if (arguments is Map && arguments['initialIndex'] is int) {
      final int initialIndex = arguments['initialIndex'] as int;
      if (initialIndex >= 0 && initialIndex < screen.length) {
        currentIndex.value = initialIndex;
      }
    }
    super.onInit();
  }
}

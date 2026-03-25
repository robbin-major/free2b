import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_template/modules/dashboard/bookmark/controller/book_mark_controller.dart';
import 'package:flutter_template/modules/dashboard/calender/controller/celender_controller.dart';
import 'package:flutter_template/modules/dashboard/dash_board/controller/dash_controller.dart';
import 'package:flutter_template/modules/dashboard/profile/controller/profile_controller.dart';
import 'package:flutter_template/utils/app_colors.dart';
import 'package:flutter_template/utils/app_string.dart';
import 'package:flutter_template/utils/assets.dart';
import 'package:get/get.dart';

import '../../../../utils/enum/common_enums.dart';

class DashBoard extends StatelessWidget {
  DashBoard({super.key});

  final DashBoardController _dashBoardController = Get.put(DashBoardController());
  final BookMarkController bookMarkController = Get.put(BookMarkController());
  final CalenderController calenderController = Get.put(CalenderController());

  // final ProfileController _profileController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Obx(
        () {
          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(systemNavigationBarColor: AppColors.backgroundLightColor));
          return BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: AppColors.backgroundLightColor,
            selectedItemColor: AppColors.textColor,
            currentIndex: _dashBoardController.currentIndex.value,
            unselectedItemColor: AppColors.unselectedIconColor,
            showUnselectedLabels: true,
            selectedLabelStyle: TextStyle(fontSize: 12.sp),
            unselectedLabelStyle: TextStyle(fontSize: 12.sp),
            showSelectedLabels: true,
            onTap: (value) async {
              _dashBoardController.onPageChanged(value);
              if (value == 1) {
                print(value);
                await calenderController.doGetEventData();
              }
              if (value == 2) {
                await bookMarkController.getBookMark();
              }
            },
            items: [
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  IconAsset.selectedHomeIcon,
                  color: _dashBoardController.currentIndex.value == 0 ? AppColors.textColor : AppColors.unselectedIconColor,
                ).paddingOnly(bottom: 6.h, top: 6.h),
                label: AppString.home.tr,
                backgroundColor: AppColors.backgroundLightColor,
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  IconAsset.calenderIcon,
                  color: _dashBoardController.currentIndex.value == 1 ? AppColors.textColor : AppColors.unselectedIconColor,
                ).paddingOnly(bottom: 6.h, top: 6.h),
                label: AppString.calendar.tr,
                backgroundColor: AppColors.backgroundLightColor,
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  IconAsset.bookMark,
                  color: _dashBoardController.currentIndex.value == 2 ? AppColors.textColor : AppColors.unselectedIconColor,
                ).paddingOnly(bottom: 6.h, top: 6.h),
                label: AppString.bookmark.tr,
                backgroundColor: AppColors.backgroundLightColor,
              ),
              BottomNavigationBarItem(
                icon: SvgPicture.asset(
                  IconAsset.profileIcon,
                  color: _dashBoardController.currentIndex.value == 3 ? AppColors.textColor : AppColors.unselectedIconColor,
                ).paddingOnly(bottom: 6.h, top: 6.h),
                label: AppString.profile.tr,
                backgroundColor: AppColors.backgroundLightColor,
              ),
            ],
          );
        },
      ),
      body: WillPopScope(
          onWillPop: () {
            return _dashBoardController.onWillPop();
          },
          child: Obx(() => IndexedStack(children: [_dashBoardController.screen[_dashBoardController.currentIndex.value]]))),
    );
  }
}

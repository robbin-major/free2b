import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/modules/dashboard/profile/controller/profile_controller.dart';
import 'package:flutter_template/utils/app_colors.dart';
import 'package:flutter_template/utils/app_string.dart';
import 'package:flutter_template/utils/navigation_utils/navigation.dart';
import 'package:flutter_template/utils/navigation_utils/routes.dart';
import 'package:flutter_template/widget/appbar.dart';
import 'package:flutter_template/widget/common_text.dart';
import 'package:flutter_template/widget/custom_button.dart';
import 'package:flutter_template/widget/custom_loading_widget.dart';
import 'package:flutter_template/widget/custom_switch_Button.dart';
import 'package:get/get.dart';

import '../../../../utils/remove_data/remove_data_service.dart';

class AccountSetting extends StatefulWidget {
  const AccountSetting({Key? key}) : super(key: key);

  @override
  State<AccountSetting> createState() => _AccountSettingState();
}

class _AccountSettingState extends State<AccountSetting> {
  final ProfileController _profileController = Get.find();

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.black, // Set your desired color
    ));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomAppBar(
        title: AppString.accountSettings,
        color: AppColors.backgroundColor,
        centerTitle: false,
        leadingWidth: 25.w,
        automaticallyImplyLeading: true,
        leading: IconButton(
          onPressed: () {
            _profileController.isDeleteLoading.value ? null : Navigation.pop();
          },
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: AppColors.textColor,
            // size: 2.5.h,
          ),
        ),
      ),
      bottomNavigationBar: CustomButton(
        buttonColor: AppColors.bottomSheetColor,
        text: AppString.deleteAccount,
        textColor: AppColors.redColor,
        height: Get.height * 0.06,
        margin: EdgeInsets.only(bottom: 16.h),
        onTap: () {
          _profileController.isDeleteLoading.value
              ? null
              : showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      titlePadding: EdgeInsets.zero,
                      backgroundColor: AppColors.backgroundLightColor,
                      shape: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
                      title: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CommonText(
                            text: AppString.doYouWantToDeleteTheAccount,
                            textAlign: TextAlign.center,
                            fontWeight: FontWeight.w500,
                            fontSize: 18.sp,
                          ).paddingOnly(bottom: 10.h, top: 20.h).paddingSymmetric(horizontal: 16.w),
                          CommonText(
                            text: AppString.readyToSayGoodByeDeletingYourAccountWillRemoveAllYourDataFromOurEventApp,
                            color: AppColors.textLightColor,
                            textAlign: TextAlign.center,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w400,
                          ).paddingSymmetric(horizontal: 16.w).paddingOnly(bottom: 20.h),
                          const Divider(height: 0),
                          GestureDetector(
                            onTap: () async {
                              Navigation.pop();
                              // await _profileController.deleteAccount();
                              await _profileController.deleteAccount().then((value) => Navigation.pushNamed(Routes.getStarted));
                            },
                            child: Container(
                              color: Colors.transparent,
                              child: CommonText(
                                text: AppString.deleteAccount,
                                color: AppColors.redColor,
                                textAlign: TextAlign.center,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                              ).paddingSymmetric(horizontal: 16.w).paddingSymmetric(vertical: 10.h),
                            ),
                          ),
                          const Divider(height: 0),
                          GestureDetector(
                            onTap: () {
                              Navigation.pop();
                            },
                            child: Container(
                              color: Colors.transparent,
                              child: CommonText(
                                text: AppString.cancel,
                                textAlign: TextAlign.center,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w500,
                              ).paddingSymmetric(horizontal: 16.w).paddingSymmetric(vertical: 10.h),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
        },
      ).paddingSymmetric(horizontal: 16.w, vertical: Platform.isIOS ? 25.h : 0),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CommonText(
                text: AppString.notificationOptions,
                color: AppColors.textLightColor,
                fontWeight: FontWeight.w600,
                fontSize: 14.sp,
              ).paddingOnly(top: 22.h).paddingSymmetric(horizontal: 16.w),
              Container(
                color: const Color(0xFF1F1F1F),
                margin: EdgeInsets.only(top: 12.h),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText(
                          text: AppString.notifications,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ).paddingOnly(bottom: 5.h),
                        CommonText(
                          text: AppString.turnOnAndOffNotifications,
                          color: AppColors.textLightColor,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ],
                    ),
                    const Spacer(),
                    Obx(() {
                      return CustomSwitchButton(
                        isSelected: _profileController.isNotification.value,
                        onTap: () {
                          _profileController.isNotification.toggle();
                        },
                      );
                    }),
                  ],
                ),
              )
            ],
          ),
          _profileController.isDeleteLoading.value
              ? Container(height: Get.height, width: Get.width, color: Colors.black12, child: const CustomLoadingWidget())
              : const SizedBox(),
        ],
      ),
    );
  }
}

// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_template/utils/app_preferences.dart';
import 'package:get/get.dart';

import '../../../../utils/app_colors.dart';
import '../../../../utils/app_string.dart';
import '../../../../utils/assets.dart';
import '../../../../utils/navigation_utils/navigation.dart';
import '../../../../utils/navigation_utils/routes.dart';
import '../../../../utils/size_utils.dart';
import '../../../../utils/utils.dart';
import '../../../../widget/appbar.dart';
import '../controller/profile_setting_controller.dart';

class LanguageSetting extends StatefulWidget {
  const LanguageSetting({super.key});

  @override
  State<LanguageSetting> createState() => _LanguageSettingState();
}

class _LanguageSettingState extends State<LanguageSetting> {
  ProfileSettingController _profileSettingController = ProfileSettingController();

  @override
  Widget build(BuildContext context) {
    print(AppPreference.getInt("languageIndex"));

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomAppBar(
        title: AppString.language.tr,
        centerTitle: false,
        automaticallyImplyLeading: Get.arguments == "ProfileScreen" ? true : false,
        color: AppColors.backgroundColor,
      ),
      body: ListView.builder(
        itemCount: Utils.locale.length,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              _profileSettingController.languageSelection.value = index;
              Get.arguments == "ProfileScreen" ? AppPreference.setInt("languageIndex", index) : print("After Splash Screen");
              Utils.updateLanguage(
                Utils.locale[index]['locale'],
              );
              setState(() {});
            },
            child: Container(
              width: double.infinity,
              height: 55.h,
              decoration: BoxDecoration(
                color: AppColors.dividerColor,
                border:
                    Border.all(color: index == _profileSettingController.languageSelection.value ? AppColors.yellowButtonColor : Colors.transparent),
                borderRadius: BorderRadius.all(
                  Radius.circular(8.r),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    Utils.locale[index]['name'],
                    style: TextStyle(
                      color: AppColors.textColor,
                      fontWeight: FontWeight.w500,
                      fontSize: SizeUtils.fSize_13(),
                      letterSpacing: 0.5,
                    ),
                  ),
                  Icon(
                    Icons.task_alt,
                    color: index == _profileSettingController.languageSelection.value ? AppColors.yellowButtonColor : Colors.transparent,
                  )
                ],
              ).paddingOnly(left: 10.w, right: 10.w),
            ).paddingOnly(top: 8.h, bottom: 8.w),
          );
        },
      ).paddingAll(14.h),
      bottomNavigationBar: Get.arguments == "ProfileScreen"
          ? SizedBox()
          : GestureDetector(
              onTap: () {
                _profileSettingController.languageSelection.value == null
                    ? {}
                    : {
                        AppPreference.setInt("languageIndex", _profileSettingController.languageSelection.value ?? 0),
                        _profileSettingController.languageSelection.value == 0
                            ? Utils.updateLanguage(const Locale('en', 'US'))
                            : Utils.updateLanguage(const Locale('es', 'ES')),
                        Navigation.pushNamed(Routes.getStarted),
                      };
              },
              child: Container(
                width: double.infinity,
                height: 55.h,
                decoration: BoxDecoration(
                  color: AppColors.yellowButtonColor,
                  border: Border.all(color: Colors.transparent),
                  borderRadius: BorderRadius.all(
                    Radius.circular(8.r),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      AppString.continueText.tr,
                      style: TextStyle(
                        color: AppColors.textColor,
                        fontWeight: FontWeight.w500,
                        fontSize: 17.sp,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ).paddingOnly(left: 10.w, right: 10.w),
              ).paddingOnly(bottom: 10.h, left: 10.w, right: 10.w),
            ),
    );
  }
}

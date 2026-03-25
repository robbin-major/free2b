import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/utils/app_colors.dart';
import 'package:flutter_template/utils/app_string.dart';
import 'package:flutter_template/utils/navigation_utils/navigation.dart';
import 'package:flutter_template/utils/navigation_utils/routes.dart';
import 'package:flutter_template/widget/common_text.dart';
import 'package:get/get.dart';

void userLoginPopup(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: AppColors.backgroundLightColor,
        titlePadding: EdgeInsets.zero,
        shape: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r)),
        title: Column(
          children: [
            CommonText(
              text: AppString.pleaseLogInToContinue,
              textAlign: TextAlign.center,
              fontWeight: FontWeight.w500,
              fontSize: 18.sp,
            ).paddingOnly(bottom: 20.h, top: 20.h).paddingSymmetric(horizontal: 16.w),
            const Divider(height: 0),
            GestureDetector(
              onTap: () async {
                Navigation.replaceAll(Routes.getStarted);
              },
              child: Container(
                color: Colors.transparent,
                child: Center(
                  child: CommonText(
                    text: AppString.login,
                    color: AppColors.redColor,
                    textAlign: TextAlign.center,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ).paddingSymmetric(horizontal: 16.w, vertical: 12.h),
              ),
            ),
            const Divider(height: 0),
            GestureDetector(
              onTap: () {
                Navigation.pop();
              },
              child: Container(
                color: Colors.transparent,
                child: Center(
                  child: CommonText(
                    text: AppString.cancel,
                    textAlign: TextAlign.center,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ).paddingSymmetric(horizontal: 16.w, vertical: 12.h),
              ),
            ),
          ],
        ),
      );
    },
  );
}

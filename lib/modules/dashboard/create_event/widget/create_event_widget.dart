import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_template/modules/dashboard/create_event/controller/create_event_controller.dart';
import 'package:flutter_template/utils/app_colors.dart';
import 'package:flutter_template/utils/app_string.dart';
import 'package:flutter_template/utils/assets.dart';
import 'package:flutter_template/widget/common_text.dart';
import 'package:flutter_template/widget/custom_textfeild.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../utils/utils.dart';

class CreateEventWidget extends StatelessWidget {
  CreateEventWidget({super.key});

  final CreateEventController _createEventController = Get.find();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(
            () => GestureDetector(
              onTap: () {
                _createEventController.getImage();
              },
              child: Container(
                height: Get.height * 0.43,
                decoration: BoxDecoration(
                  color: _createEventController.pictureGallery.value.isNotEmpty
                      ? Colors.transparent
                      : AppColors.bottomSheetColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: _createEventController.pictureGallery.value.isNotEmpty
                    ? Align(
                        alignment: Alignment.center,
                        child: Image.file(
                          File(_createEventController.pictureGallery.value),
                          fit: BoxFit.fill,
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(IconAsset.uploadImageIcon),
                          Center(
                            child: CommonText(
                              text: AppString.tapToAddaCoverImageOfEvent,
                              color: AppColors.textLightColor,
                              fontSize: 12.sp,
                            ),
                          )
                        ],
                      ),
              ).paddingOnly(bottom: 24.h),
            ),
          ),
          CustomTextField(
            controller: _createEventController.titleController,
            floatingLabelBehavior: FloatingLabelBehavior.always,
            labelStyle: TextStyle(color: AppColors.textColor),
            fillColor: AppColors.backgroundColor,
            labelText: AppString.title.tr,
            hintText: AppString.enterEventTitleHere.tr,
          ).paddingOnly(bottom: 16.h),
          CommonText(
            text: AppString.schedule,
            fontSize: 12.sp,
            color: AppColors.textLightColor,
          ).paddingOnly(bottom: 12.h),
          Obx(
            () => GestureDetector(
              onTap: () async {
                Utils.hideKeyboardInApp(context);
                var date = await _createEventController.datePicker(context);

                date != null
                    ? {
                        _createEventController.dateOfBirth.value =
                            "${date.day}-${date.month}-${date.year}",
                        _createEventController.dob.value =
                            date.millisecondsSinceEpoch
                      }
                    : "";
              },
              child: Container(
                color: Colors.transparent,
                child: Row(
                  children: [
                    SvgPicture.asset(IconAsset.calenderIcon),
                    CommonText(
                      text: AppString.startDate,
                      fontSize: 16.sp,
                    ).paddingOnly(left: 12.w),
                    const Spacer(),
                    CommonText(
                      text: _createEventController.dateOfBirth.value.isNotEmpty
                          ? _createEventController.dateOfBirth.value
                          : AppString.add,
                      fontSize: 14.sp,
                    ).paddingOnly(right: 6.w),
                    Icon(
                      CupertinoIcons.right_chevron,
                      color: AppColors.textLightColor,
                      size: 20.sp,
                    )
                  ],
                ),
              ),
            ),
          ),
          Divider(height: 0.h).paddingSymmetric(vertical: 12.h),
          Obx(
            () => GestureDetector(
              onTap: () async {
                Utils.hideKeyboardInApp(context);
                var date = await _createEventController.timePicker(context);

                date != null
                    ? _createEventController.timeToday.value =
                        "${date.hour}:${date.minute}"
                    : "";
                DateTime dateTime = DateFormat("HH:mm")
                    .parse(_createEventController.timeToday.value);
                String time12 = DateFormat("hh:mm a").format(dateTime);
                _createEventController.timeToday.value = time12;
              },
              child: Container(
                color: Colors.transparent,
                child: Row(
                  children: [
                    SvgPicture.asset(IconAsset.timeIcon),
                    CommonText(
                      text: AppString.startTime,
                      fontSize: 16.sp,
                    ).paddingOnly(left: 12.w),
                    const Spacer(),
                    CommonText(
                      text: _createEventController.timeToday.value.isNotEmpty
                          ? _createEventController.timeToday.value
                          : AppString.add,
                      fontSize: 14.sp,
                    ).paddingOnly(right: 6.w),
                    Icon(
                      CupertinoIcons.right_chevron,
                      color: AppColors.textLightColor,
                      size: 20.sp,
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

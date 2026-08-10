import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/utils/app_colors.dart';
import 'package:flutter_template/utils/app_string.dart';
import 'package:flutter_template/widget/appbar.dart';
import 'package:flutter_template/widget/common_text.dart';
import 'package:get/get.dart';

class MessagesScreen extends StatelessWidget {
  const MessagesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomAppBar(
        color: AppColors.backgroundColor,
        title: AppString.messages,
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: AppColors.backgroundLightColor,
                borderRadius: BorderRadius.circular(8.r),
                border: Border.all(
                  color: AppColors.yellowButtonColor.withOpacity(0.28),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    height: 46.w,
                    width: 46.w,
                    decoration: BoxDecoration(
                      color: AppColors.yellowButtonColor.withOpacity(0.14),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.chat_bubble_outline_rounded,
                      color: AppColors.yellowButtonColor,
                      size: 24.sp,
                    ),
                  ),
                  12.w.horizontalSpace,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CommonText(
                          text: 'Messages coming soon',
                          color: AppColors.textColor,
                          fontSize: 17.sp,
                          fontWeight: FontWeight.w800,
                        ),
                        5.h.verticalSpace,
                        CommonText(
                          text:
                              'Event chats, friend plans, and community notes will live here.',
                          color: AppColors.textLightColor,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                          softWrap: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

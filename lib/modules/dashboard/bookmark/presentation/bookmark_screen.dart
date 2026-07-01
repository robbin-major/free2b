import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_template/modules/dashboard/bookmark/controller/book_mark_controller.dart';
import 'package:flutter_template/utils/app_colors.dart';
import 'package:flutter_template/utils/app_string.dart';
import 'package:flutter_template/utils/auth_session_service.dart';
import 'package:flutter_template/utils/assets.dart';
import 'package:flutter_template/utils/navigation_utils/navigation.dart';
import 'package:flutter_template/utils/navigation_utils/routes.dart';
import 'package:flutter_template/utils/utils.dart';
import 'package:flutter_template/widget/appbar.dart';
import 'package:flutter_template/widget/common_text.dart';
import 'package:flutter_template/widget/custom_loading_widget.dart';
import 'package:flutter_template/widget/event_image.dart';
import 'package:get/get.dart';

import '../../../get_started/presentation/get_started_screen.dart';

class BookMarkScreen extends StatelessWidget {
  BookMarkScreen({super.key});

  final BookMarkController bookMarkController = Get.put(BookMarkController());

  @override
  Widget build(BuildContext context) {
    return AuthSessionService.isSignedIn
        ? Scaffold(
            backgroundColor: AppColors.backgroundColor,
            appBar: CustomAppBar(
              color: AppColors.backgroundColor,
              title: AppString.bookmark,
              centerTitle: false,
              automaticallyImplyLeading: false,
            ),
            body: RefreshIndicator(
              onRefresh: () async {
                bookMarkController.getBookMark();
              },
              child: Obx(
                () => bookMarkController.isBookMarkLoading.value
                    ? const CustomLoadingWidget()
                    : bookMarkController.bookMarkEvent.isEmpty
                        ? ListView(
                            children: [
                              _socialTeaser().paddingSymmetric(
                                horizontal: 16.w,
                                vertical: 12.h,
                              ),
                              SizedBox(
                                height: Get.height * 0.55,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.max,
                                    children: [
                                      SvgPicture.asset(IconAsset.smileys),
                                      12.h.verticalSpace,
                                      CommonText(
                                        text: AppString.noEventFound,
                                        color: AppColors.textLightColor,
                                        fontSize: 20.sp,
                                        fontWeight: FontWeight.w500,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            itemCount: bookMarkController.bookMarkEvent.length + 1,
                            itemBuilder: (context, index) {
                              if (index == 0) {
                                return _socialTeaser().paddingSymmetric(
                                  horizontal: 16.w,
                                  vertical: 12.h,
                                );
                              }

                              final eventData =
                                  bookMarkController.bookMarkEvent[index - 1];
                              return GestureDetector(
                                behavior: HitTestBehavior.translucent,
                                onTap: () async {
                                  await Navigation.pushNamed(Routes.detailsScreen, arg: eventData).then((value) async {
                                    print("GestureDetector");
                                    await bookMarkController.getBookMark();
                                  });
                                },
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      children: [
                                        Hero(
                                          tag: index,
                                          transitionOnUserGestures: true,
                                          child: EventImage(
                                            imageUrl: eventData.image,
                                            height: 146.h,
                                            width: 130.w,
                                            borderRadius:
                                                BorderRadius.circular(7.58.r),
                                          ),
                                        ),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              CommonText(
                                                text: eventData.title ?? "",
                                                fontWeight: FontWeight.w700,
                                                fontSize: 18.sp,
                                                maxLine: 2,
                                                softWrap: true,
                                              ).paddingOnly(bottom: 12.h),
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  SvgPicture.asset(IconAsset.dateTimeIcon).paddingOnly(right: 8.w),
                                                  Expanded(
                                                    child: Row(
                                                      children: [
                                                        CommonText(
                                                          // text:
                                                          //     "${Utils.changeFormat(
                                                          //   date: eventData
                                                          //       .startDate
                                                          //       .toString(),
                                                          // )}",

                                                          text: "${Utils.getFormattedDate(
                                                            format: "dd-MM-yyyy",
                                                            date: eventData.startDate.toString(),
                                                          )} at ${_eventTimeText(eventData.startDate)}",
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: 12.sp,
                                                          softWrap: true,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ).paddingOnly(bottom: 6.h),
                                              Row(
                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                children: [
                                                  SvgPicture.asset(IconAsset.locationIcon).paddingOnly(right: 8.w),
                                                  Expanded(
                                                    child: CommonText(
                                                      text: AppTempString.tempEventLocation,
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 12.sp,
                                                      softWrap: true,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ).paddingOnly(left: 12.w),
                                        ),
                                      ],
                                    ).paddingSymmetric(horizontal: 16.w),
                                    Divider(color: AppColors.dividerColor).paddingSymmetric(vertical: 8.h),
                                  ],
                                ),
                              );
                            },
                          ),
              ),
            ),
          )
        : const GetStartedScreen(
            isAnonymous: true,
          );
  }

  Widget _socialTeaser() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundLightColor,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(
          color: AppColors.yellowButtonColor.withValues(alpha: 0.34),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.auto_awesome,
            color: AppColors.yellowButtonColor,
            size: 18.sp,
          ).paddingOnly(top: 2.h),
          Expanded(
            child: CommonText(
              text: AppString.bookmarkSocialTeaser,
              color: AppColors.textColor,
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              softWrap: true,
            ).paddingOnly(left: 10.w),
          ),
        ],
      ),
    );
  }

  String _eventTimeText(String? startDate) {
    final List<String> dateParts = (startDate ?? '').trim().split(' ');

    if (dateParts.length < 2 || dateParts[1].isEmpty) {
      return '--';
    }

    return Utils.getDateTime(
      format: "hh:mm a",
      date: startDate.toString(),
    );
  }
}

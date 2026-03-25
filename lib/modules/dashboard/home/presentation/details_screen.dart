import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_template/modules/dashboard/home/controller/details_controller.dart';
import 'package:flutter_template/utils/app_colors.dart';
import 'package:flutter_template/utils/assets.dart';
import 'package:flutter_template/utils/common_service/app_pref_service.dart';
import 'package:flutter_template/utils/navigation_utils/navigation.dart';
import 'package:flutter_template/utils/utils.dart';
import 'package:flutter_template/widget/common_text.dart';
import 'package:flutter_template/widget/custom_loading_widget.dart';
import 'package:flutter_template/widget/login_popup.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';

class DetailsScreen extends StatelessWidget {
  DetailsScreen({super.key});

  final DetailController _detailController = Get.put(DetailController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Stack(
                children: [
                  Hero(
                    tag: _detailController.eventModel.image ?? '',
                    child: CachedNetworkImage(
                      width: Get.width,
                      height: 400.h,
                      filterQuality: FilterQuality.none,
                      imageUrl: _detailController.eventModel.image ?? '',
                      fit: BoxFit.cover,
                      errorWidget: (context, url, error) {
                        return SizedBox(
                            height: Get.height * 0.25,
                            child: const Icon(Icons.error));
                      },
                      progressIndicatorBuilder: (context, url, progress) {
                        return SizedBox(
                            height: Get.height * 0.2,
                            child: const CustomLoadingWidget());
                      },
                    ),
                  ),
                  Row(
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          Navigation.pop();
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.textColor,
                            shape: BoxShape.circle,
                          ),
                          padding: EdgeInsets.all(8.h),
                          child: SvgPicture.asset(IconAsset.backIcon),
                        ),
                      ),
                      const Spacer(),
                      GestureDetector(
                        onTap: () async {

                          // final androidUrl = 'https://play.google.com/store/apps/details?id=com.free2bapp.mobile';
                          // final iosUrl = 'https://apps.apple.com/app/id6550897448';

                          final downloadUrl = 'https://appurl.io/UIg7_O0amY';

                          final title = _detailController.eventModel.title?.toUpperCase() ?? '';

                          final params = ShareParams(
                            subject: title,
                            title: title,
                            text: '**$title**\n\n'
                                '${_detailController.eventModel.description!.join("\n")}\n\n'
                                '✨ Find more free Chicago events on the Free2B app:\n'
                                '👉🏾 $downloadUrl\n',
                          );

                          final result = await SharePlus.instance.share(params);

                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.textColor,
                            shape: BoxShape.circle,
                          ),
                          padding: EdgeInsets.all(8.h),
                          child: SvgPicture.asset(
                            IconAsset.shareIcon,
                            height: 21.h,
                            width: 21.w,
                          ),
                        ),
                      ),
                      if (_detailController.eventModel.uid ==
                          AppPrefService.getUserUid())
                        const SizedBox.shrink()
                      else
                        Obx(
                          () => GestureDetector(
                            onTap: () async {
                              final String userID = AppPrefService.getUserUid();
                              _detailController.isBookMark.toggle();
                              if (userID.isNotEmpty) {
                                bool isBookMark = _detailController
                                        .userData.value?.bookmark
                                        ?.any((element) =>
                                            element ==
                                            _detailController
                                                .eventModel.eventID) ??
                                    false;
                                if (isBookMark) {
                                  _detailController.bookMarkId.remove(
                                      _detailController.eventModel.eventID ??
                                          "");
                                  await _detailController.eventBookMark();
                                } else {
                                  _detailController.bookMarkId.add(
                                      _detailController.eventModel.eventID ??
                                          "");
                                  await _detailController.eventBookMark();
                                }
                              } else {
                                userLoginPopup(context);
                              }
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.textColor,
                                shape: BoxShape.circle,
                              ),
                              padding: EdgeInsets.all(8.h),
                              margin: EdgeInsets.only(left: 8.h),
                              child: (_detailController.userData.value?.bookmark
                                          ?.any((element) =>
                                              element ==
                                              _detailController
                                                  .eventModel.eventID) ??
                                      false)
                                  ? SvgPicture.asset(IconAsset.bookMarkDoneIcon)
                                  : SvgPicture.asset(IconAsset.bookMarkIcon),
                            ),
                          ),
                        ),
                    ],
                  ).paddingSymmetric(horizontal: 16.w, vertical: 16.h),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(
                    text: _detailController.eventModel.title ?? '',
                    fontWeight: FontWeight.w700,
                    fontSize: 32.sp,
                  ).paddingOnly(top: 20.h, bottom: 12.h),
                  Row(
                    children: [
                      SvgPicture.asset(IconAsset.dateTimeIcon)
                          .paddingOnly(right: 8.w),
                      CommonText(
                        text: "${Utils.getFormattedDate(
                          format: "dd MMM yyyy",
                          date:
                              _detailController.eventModel.startDate.toString(),
                        )} at ${_detailController.eventModel.startDate!.split(" ")[1] == "" ? "--" : Utils.getDateTime(
                            format: "hh:mm a",
                            date: _detailController.eventModel.startDate
                                .toString(),
                          )}",
                        fontWeight: FontWeight.w600,
                        fontSize: 12.sp,
                      ),
                    ],
                  ).paddingOnly(bottom: 6.h),
                  GestureDetector(
                    onTap: () {
                      print("google map");
                      _detailController.getLatLngFromAddress(
                          "${_detailController.eventModel.address} ${_detailController.eventModel.city} ${_detailController.eventModel.state} ${_detailController.eventModel.country}");
                    },
                    child: Row(
                      children: [
                        SvgPicture.asset(IconAsset.locationIcon)
                            .paddingOnly(right: 8.w),
                        CommonText(
                          text: (_detailController.eventModel.aptSuiteOther ??
                                  '') +
                              (_detailController.eventModel.address ?? '') +
                              (_detailController.eventModel.country ?? ''),
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
                        ),
                      ],
                    ).paddingOnly(bottom: 20.h),
                  ),
                ],
              ).paddingSymmetric(horizontal: 16.w),
              Divider(color: AppColors.dividerColor),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _detailController.eventModel.description?.length ?? 0,
                itemBuilder: (context, index) {
                  var value = _detailController.eventModel.description?[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 15.0), // Adjust spacing here
                    child: RichText(
                      text: TextSpan(
                        children: _detailController.getStyledText(text: value ?? ""),
                      ),
                    ),
                  );
                },
              ).paddingSymmetric(horizontal: 16.w),
              SizedBox(height: 20.h)
            ],
          ),
        ),
      ),
    );
  }
}

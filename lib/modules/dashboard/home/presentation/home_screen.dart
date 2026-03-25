import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_template/modules/dashboard/home/controller/home_controller.dart';
import 'package:flutter_template/utils/app_colors.dart';
import 'package:flutter_template/utils/app_string.dart';
import 'package:flutter_template/utils/assets.dart';
import 'package:flutter_template/utils/navigation_utils/navigation.dart';
import 'package:flutter_template/utils/navigation_utils/routes.dart';
import 'package:flutter_template/utils/utils.dart';
import 'package:flutter_template/widget/appbar.dart';
import 'package:flutter_template/widget/common_text.dart';
import 'package:flutter_template/widget/custom_loading_widget.dart';
import 'package:flutter_template/widget/custom_search_bar.dart';
import 'package:get/get.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key}) : super(key: key);
  final HomeController _homeController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomAppBar(
        title: AppString.home,
        centerTitle: false,
        automaticallyImplyLeading: false,
        color: AppColors.backgroundColor,
        actions: [
          GestureDetector(
            onTap: () async {
              // await _homeController.getEvent();
            },
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.backgroundLightColor,
              ),
              padding: EdgeInsets.all(4.sp),
              margin: EdgeInsets.only(right: 16.w),
              child: SvgPicture.asset(
                IconAsset.notificationIcon,
                height: 24.h,
                width: 24.w,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(
            () {
              print(_homeController.isSearch.value);
              return CustomSearchBar(
                isLeading: true,
                backgroundColor:
                    MaterialStatePropertyAll(AppColors.backgroundLightColor),
                leading: SvgPicture.asset(IconAsset.searchIcon)
                    .paddingOnly(left: 6.w),
                hintText: AppString.searchHint.tr,
                controller: _homeController.textEditingController,
                onChanged: (String? value) {
                  _homeController.searchEvent(value: value ?? "");
                },
                trailing: [
                  _homeController.textEditingController.text.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _homeController.textEditingController.clear();
                            _homeController.getEvent();
                            _homeController.searchEvent(value: "");
                          },
                          icon: Icon(Icons.close),
                        )
                      : SizedBox()
                ],
                hintStyle: MaterialStatePropertyAll(
                  TextStyle(
                    color: AppColors.textLightColor,
                    fontSize: 14.sp,
                  ),
                ),
              ).paddingOnly(bottom: 14.h, top: 10.h);
            },
          ),
          Obx(() {
            final showCategoryGrid = _homeController.isSearch.value &&
                _homeController.textEditingController.text.isNotEmpty &&
                _homeController.categoryList.isNotEmpty;

            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (Widget child, Animation<double> animation) {
                final slideAnimation = Tween<Offset>(
                  begin: Offset(
                      0, child.key == const ValueKey("visible") ? -0.1 : 0.1),
                  end: Offset.zero,
                ).animate(animation);

                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: slideAnimation,
                    child: child,
                  ),
                );
              },
              child: showCategoryGrid
                  ? SingleChildScrollView(
                      key: const ValueKey("visible"),
                      padding:
                          EdgeInsets.only(bottom: 5.h), // Only bottom padding
                      child: Wrap(
                        spacing: 5.w * 0.8, // Horizontal spacing between items
                        runSpacing: 5.h * 0.8, // Vertical spacing
                        children: _homeController.categoryList.map((category) {
                          final textLength = category.length;
                          double boxWidth =
                              (textLength * 10).w * 0.8 + 40.w * 0.7;
                          boxWidth = boxWidth.clamp(
                              70.w, (MediaQuery.of(context).size.width - 48.w));

                          return Container(
                            constraints: BoxConstraints(
                              minWidth: 70.w,
                              maxWidth: boxWidth,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.r * 0.8),
                              gradient: const LinearGradient(
                                colors: [Color(0xFFF6E27F), Color(0xFFD4AF37)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(15.r * 0.8),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(15.r * 0.8),
                                onTap: () {
                                  _homeController.textEditingController.text =
                                      category;
                                  _homeController.searchEvent(value: category);
                                },
                                splashColor: Colors.white.withOpacity(0.2),
                                highlightColor: Colors.transparent,
                                child: Padding(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 12.w * 0.8,
                                    vertical: 8.h * 0.8,
                                  ),
                                  child: Center(
                                    child: CommonText(
                                      text: category,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12.sp * 0.8,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    )
                  : const SizedBox(
                      key: ValueKey("invisible"),
                    ),
            );
          }),
          Expanded(
            child: Obx(
              () => _homeController.isEventLoading.value
                  ? const CustomLoadingWidget()
                  : (!_homeController.isSearch.value
                          ? (_homeController.eventData.isEmpty)
                          : (_homeController.searchEventData.isEmpty))
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
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
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            await _homeController.getEvent();
                          },
                          child: ListView.builder(
                            itemCount: _homeController.isSearch.value
                                ? _homeController.searchEventData.length
                                : _homeController.eventData.length,
                            itemBuilder: (context, index) {
                              var data = _homeController.isSearch.value
                                  ? _homeController.searchEventData[index]
                                  : _homeController.eventData[index];
                              timeDilation = 1.0;
                              return GestureDetector(
                                onTap: () async {
                                  Navigation.pushNamed(Routes.detailsScreen,
                                      arg: data);
                                },
                                child: Hero(
                                  tag: data.image ?? "0",
                                  transitionOnUserGestures: true,
                                  child: Container(
                                    height: 400.h,
                                    width: Get.width,
                                    margin:
                                        EdgeInsets.symmetric(vertical: 10.h),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(20.r),
                                        topRight: Radius.circular(20.r),
                                      ),
                                      image: (data.image?.isNotEmpty ?? false)
                                          ? DecorationImage(
                                              image: NetworkImage(
                                                  data.image ?? ''),
                                              fit: BoxFit.cover,
                                            )
                                          : const DecorationImage(
                                              image: AssetImage(
                                                TempImage.tempImage1,
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          child: Container(
                                            color:
                                                Colors.black.withOpacity(0.4),
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 0,
                                          child: Container(
                                            height: 80.h,
                                            width: Get.width,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.transparent,
                                                  AppColors.backgroundColor
                                                      .withOpacity(0.7),
                                                  AppColors.backgroundColor,
                                                ],
                                                begin: Alignment.topCenter,
                                                end: Alignment.bottomCenter,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Column(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Align(
                                              alignment: Alignment.topRight,
                                              child: Container(
                                                padding: EdgeInsets.only(
                                                    left: 10.w, right: 10.w),
                                                decoration: BoxDecoration(
                                                  color: AppColors.textColor,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.r),
                                                ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    SizedBox(
                                                      height: 34.h,
                                                      width: 40.w,
                                                      child: Center(
                                                        child: CommonText(
                                                          text: Utils
                                                              .getFormattedDate(
                                                                  format: "dd",
                                                                  date:
                                                                      data.startDate ??
                                                                          '00'),
                                                          color: AppColors
                                                              .backgroundLightColor,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontSize: 28.sp,
                                                        ),
                                                      ),
                                                    ).paddingOnly(top: 12.h),
                                                    SizedBox(
                                                      height: 19.h,
                                                      width: 40.w,
                                                      child: Center(
                                                        child: CommonText(
                                                          text: Utils
                                                              .getFormattedDate(
                                                                  format: "MMM",
                                                                  date: data
                                                                          .startDate ??
                                                                      "100"),
                                                          color: AppColors
                                                              .disableButtonColor,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          fontSize: 14.sp,
                                                        ),
                                                      ),
                                                    ).paddingOnly(bottom: 10.h),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            const Spacer(),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                CommonText(
                                                  text: data.title ?? '',
                                                  maxLine: 2,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 32.sp,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  // ),
                                                ).paddingOnly(bottom: 4.h),
                                                CommonText(
                                                  text: ((data.aptSuiteOther ??
                                                          "") +
                                                      (data.address ?? '') +
                                                      (data.country ?? "")),
                                                  fontWeight: FontWeight.w700,
                                                  maxLine: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  textDecoration:
                                                      TextDecoration.underline,
                                                  fontSize: 12.sp,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ).paddingSymmetric(
                                            horizontal: 16.w, vertical: 16.h),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
            ),
          )
        ],
      ).paddingSymmetric(horizontal: 16.w),
    );
  }
}

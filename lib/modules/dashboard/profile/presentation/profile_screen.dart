import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_template/modules/dashboard/profile/controller/profile_controller.dart';
import 'package:flutter_template/modules/get_started/presentation/get_started_screen.dart';
import 'package:flutter_template/utils/app_colors.dart';
import 'package:flutter_template/utils/app_string.dart';
import 'package:flutter_template/utils/assets.dart';
import 'package:flutter_template/utils/common_service/app_pref_service.dart';
import 'package:flutter_template/utils/enum/common_enums.dart';
import 'package:flutter_template/utils/navigation_utils/navigation.dart';
import 'package:flutter_template/utils/navigation_utils/routes.dart';
import 'package:flutter_template/utils/utils.dart';
import 'package:flutter_template/widget/appbar.dart';
import 'package:flutter_template/widget/common_text.dart';
import 'package:flutter_template/widget/custom_loading_widget.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../utils/remove_data/remove_data_service.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final ProfileController _profileController = Get.put(ProfileController());
  TabController? tabController;

  @override
  void initState() {
    tabController = TabController(
        length: 2,
        vsync: this,
        initialIndex: _profileController.selectedIndex.value);
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppPrefService.getUserUid().isNotEmpty
        ? Scaffold(
            floatingActionButton: Obx(
              () {
                return GestureDetector(
                  onTap: () => Navigation.pushNamed(Routes.createEvent),
                  child: AnimatedContainer(
                    decoration: BoxDecoration(
                      color: AppColors.yellowButtonColor,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    padding:
                        EdgeInsets.symmetric(vertical: 8.h, horizontal: 12.w),
                    duration: const Duration(seconds: 3),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(IconAsset.plusIcon),
                        (_profileController.isScrolling.value)
                            ? const SizedBox.shrink()
                            : const CommonText(text: AppString.createEvent)
                                .paddingOnly(left: 8.w),
                      ],
                    ),
                  ),
                );
              },
            ),
            backgroundColor: AppColors.backgroundColor,
            appBar: CustomAppBar(
              automaticallyImplyLeading: false,
              centerTitle: false,
              title: AppString.profile,
              color: AppColors.backgroundColor,
              actions: [
                GestureDetector(
                  onTap: () {
                    SystemChrome.setSystemUIOverlayStyle(
                      SystemUiOverlayStyle(
                        systemNavigationBarColor: AppColors
                            .bottomSheetColor, // Set your desired color
                      ),
                    );
                    showModalBottomSheet(
                      isScrollControlled: true,
                      context: context,
                      backgroundColor: AppColors.bottomSheetColor,
                      shape: OutlineInputBorder(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10.r),
                          topRight: Radius.circular(10.r),
                        ),
                        borderSide: const BorderSide(width: 0),
                      ),
                      builder: (context) {
                        return SizedBox(
                          width: Get.width,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 54.w,
                                height: 4.h,
                                margin: EdgeInsets.only(top: 16.h),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5.r),
                                  color: AppColors.disableButtonColor,
                                ),
                              ),
                              CommonText(
                                text: AppString.settings,
                                fontSize: 18.sp,
                                fontWeight: FontWeight.w500,
                              ).paddingOnly(bottom: 24.h, top: 16.h),
                              ListView.separated(
                                shrinkWrap: true,
                                separatorBuilder: (context, index) {
                                  return Divider(
                                          color: AppColors.disableButtonColor)
                                      .paddingSymmetric(vertical: 3.h);
                                },
                                itemCount:
                                    _profileController.settingList.length,
                                itemBuilder: (context, index) {
                                  var data =
                                      _profileController.settingList[index];
                                  return GestureDetector(
                                    onTap: () async {
                                      Navigation.pop();
                                      if (index == 0) {
                                        await Navigation.pushNamed(
                                            Routes.profileSettingScreen);
                                        _profileController.isLoading.value =
                                            true;
                                      } else if (index == 1) {
                                        Navigation.pushNamed(
                                            Routes.accountSetting);
                                      } else if (index == 2) {
                                        await launchUrl(
                                            Uri.parse(WebLink.privacyPolicy));
                                      } else if (index == 3) {
                                        Navigation.pushNamed(
                                            Routes.languageSetting,
                                            arg: "ProfileScreen");
                                      } else if (index == 4) {
                                        await launchUrl(Uri.parse(
                                            WebLink.termsAndCondition));
                                      } else if (index == 5) {
                                        await showDialog(
                                          context: context,
                                          builder: (context) {
                                            return AlertDialog(
                                              backgroundColor: AppColors
                                                  .backgroundLightColor,
                                              titlePadding: EdgeInsets.zero,
                                              shape: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.r)),
                                              title: Column(
                                                children: [
                                                  CommonText(
                                                    text: AppString
                                                        .areYouSureYouWantToLogout,
                                                    textAlign: TextAlign.center,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 18.sp,
                                                  )
                                                      .paddingOnly(
                                                          bottom: 10.h,
                                                          top: 20.h)
                                                      .paddingSymmetric(
                                                          horizontal: 16.w),
                                                  CommonText(
                                                    text: AppString
                                                        .readyToSayGoodbyeLogoutOfYourAccountFromOurEventApp,
                                                    color: AppColors
                                                        .textLightColor,
                                                    textAlign: TextAlign.center,
                                                    fontSize: 12.sp,
                                                    fontWeight: FontWeight.w400,
                                                  ).paddingOnly(
                                                      left: 16.w,
                                                      right: 16.w,
                                                      bottom: 20.h),
                                                  const Divider(height: 0),
                                                  GestureDetector(
                                                    onTap: () async {
                                                      var value =
                                                          await _profileController
                                                              .signOutFromGoogle();
                                                      // AppPrefService.clearAppPreferences();
                                                      RemoveDataService
                                                          .clearData();
                                                      if (value) {
                                                        Navigation.replaceAll(
                                                            Routes.getStarted);
                                                      }
                                                    },
                                                    child: Container(
                                                      color: Colors.transparent,
                                                      child: CommonText(
                                                        text: AppString.logOut,
                                                        color:
                                                            AppColors.redColor,
                                                        textAlign:
                                                            TextAlign.center,
                                                        fontSize: 16.sp,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ).paddingSymmetric(
                                                          horizontal: 16.w,
                                                          vertical: 10.h),
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
                                                        textAlign:
                                                            TextAlign.center,
                                                        fontSize: 16.sp,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ).paddingSymmetric(
                                                          horizontal: 16.w,
                                                          vertical: 10.h),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        );
                                      }
                                    },
                                    child: Container(
                                      color: Colors.transparent,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          data.endIcon,
                                          CommonText(
                                            text: data.text,
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.w400,
                                            color: (index == 5)
                                                ? AppColors.redColor
                                                : AppColors.textColor,
                                          ).paddingOnly(left: 12.w),
                                          const Spacer(),
                                          data.startIcon,
                                        ],
                                      ).paddingSymmetric(vertical: 3.h),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ).paddingSymmetric(horizontal: 16.w),
                        ).paddingOnly(bottom: 22.h);
                      },
                    ).whenComplete(() => SystemChrome.setSystemUIOverlayStyle(
                            SystemUiOverlayStyle(
                          systemNavigationBarColor: AppColors
                              .backgroundLightColor, // Set your desired color
                        )));
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.backgroundLightColor,
                      shape: BoxShape.circle,
                    ),
                    padding: EdgeInsets.all(4.sp),
                    margin: EdgeInsets.only(right: 16.w),
                    child: SvgPicture.asset(IconAsset.menuIcon),
                  ),
                ),
              ],
            ),
            body: Stack(
              children: [
                DefaultTabController(
                    length: 2,
                    child: NestedScrollView(
                      controller: _profileController.scrollController,
                      headerSliverBuilder: (context, innerBoxIsScrolled) {
                        return [
                          SliverAppBar(
                            scrolledUnderElevation: 0,
                            pinned: true,
                            expandedHeight: 260.h,
                            automaticallyImplyLeading: false,
                            backgroundColor: AppColors.backgroundColor,
                            elevation: 0,
                            flexibleSpace: FlexibleSpaceBar(
                              centerTitle: false,
                              titlePadding: EdgeInsets.zero,
                              background: Container(
                                alignment: Alignment.topCenter,
                                color: AppColors.backgroundColor,
                                child: Obx(() {
                                  return Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Center(
                                        child: (_profileController
                                                    .userData
                                                    .value
                                                    ?.profilePhoto
                                                    ?.isNotEmpty ??
                                                false)
                                            ? CachedNetworkImage(
                                                height: 110.h,
                                                width: 110.w,
                                                filterQuality:
                                                    FilterQuality.none,
                                                imageUrl: _profileController
                                                        .userData
                                                        .value
                                                        ?.profilePhoto ??
                                                    "",
                                                fit: BoxFit.cover,
                                                imageBuilder:
                                                    (context, imageProvider) =>
                                                        Container(
                                                  decoration: BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    image: DecorationImage(
                                                      image: imageProvider,
                                                      fit: BoxFit.cover,
                                                    ),
                                                  ),
                                                ),
                                                errorWidget:
                                                    (context, url, error) {
                                                  return (AppPrefService
                                                              .getProfilePhoto()
                                                          .isNotEmpty)
                                                      ? const SizedBox.shrink()
                                                      : const Icon(
                                                          Icons.person);
                                                },
                                                progressIndicatorBuilder:
                                                    (context, url, progress) {
                                                  return _profileController
                                                          .isLoading.value
                                                      ? const CustomLoadingWidget()
                                                      : const SizedBox();
                                                },
                                              ).paddingOnly(
                                                bottom: 8.h, top: 24.h)
                                            : Container(
                                                height: 110.h,
                                                width: 110.w,
                                                decoration: const BoxDecoration(
                                                    shape: BoxShape.circle,
                                                    color: Colors.red,
                                                    image: DecorationImage(
                                                      image: AssetImage(
                                                          ImagesAsset
                                                              .anonymous),
                                                    )),
                                              ).paddingOnly(
                                                bottom: 8.h, top: 24.h),
                                      ),
                                      CommonText(
                                        text: AppPrefService.getName(),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 18.sp,
                                      ),
                                    ],
                                  );
                                }),
                              ),
                              expandedTitleScale: 1,
                              title: eventTabBar(),
                            ),
                          ),
                        ];
                      },
                      body: MediaQuery.removePadding(
                        context: context,
                        removeBottom: true,
                        removeTop: true,
                        child: TabBarView(
                          clipBehavior: Clip.none,
                          controller: tabController,
                          physics: const NeverScrollableScrollPhysics(),
                          children: [
                            buildListView(),
                            buildListView(),
                          ],
                        ),
                      ),
                    )),
                Obx(() {
                  return _profileController.isLogOutLoading.value
                      ? CustomLoadingWidget(color: AppColors.yellowButtonColor)
                      : const SizedBox.shrink();
                }),
              ],
            ),
          )
        : const GetStartedScreen(
            isAnonymous: true,
          );
  }

  Widget buildListView() {
    return Obx(() {
      if (_profileController.isEventLoading.value) {
        return const Center(child: CustomLoadingWidget());
      } else {
        if ((_profileController.eventData.isEmpty)) {
          return Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(IconAsset.smileys),
                12.h.verticalSpace,
                CommonText(
                  text: AppString.noEventFound,
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          );
        } else {
          return MediaQuery.removePadding(
            context: context,
            removeTop: true,
            child: ListView.separated(
              separatorBuilder: (context, index) {
                return Divider(
                  color: AppColors.dividerColor,
                ).paddingSymmetric(vertical: 7.h);
              },
              itemCount: _profileController.eventData.length,
              shrinkWrap: true,
              primary: true,
              itemBuilder: (context, index) {
                var value = _profileController.eventData[index];
                return GestureDetector(
                  onTap: () =>
                      Navigation.pushNamed(Routes.detailsScreen, arg: value),
                  child: Container(
                    color: Colors.transparent,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Hero(
                              tag: value.image ?? '',
                              transitionOnUserGestures: true,
                              child: CachedNetworkImage(
                                height: 146.h,
                                width: 130.w,
                                filterQuality: FilterQuality.low,
                                imageUrl: value.image ?? "",
                                fit: BoxFit.cover,
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: imageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: BorderRadius.circular(7.58.r),
                                  ),
                                  height: 146.h,
                                  width: 130.w,
                                ),
                                errorWidget: (context, url, error) {
                                  return (value.image?.isNotEmpty ?? false)
                                      ? const SizedBox.shrink()
                                      : const Icon(Icons.person);
                                },
                                progressIndicatorBuilder:
                                    (context, url, progress) {
                                  return const CustomLoadingWidget();
                                },
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  CommonText(
                                    text: value.title ?? '',
                                    fontWeight: FontWeight.w700,
                                    fontSize: 18.sp,
                                    maxLine: 2,
                                    softWrap: true,
                                  ).paddingOnly(bottom: 12.h),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(IconAsset.dateTimeIcon)
                                          .paddingOnly(right: 8.w),
                                      Expanded(
                                        child: CommonText(
                                          text: "${Utils.getFormattedDate(
                                            format: "d-M-yyyy",
                                            date: "${value.startDate}",
                                          )} at "
                                              "${Utils.getDateTime(
                                            format: "hh:mm a",
                                            date: value.startDate.toString(),
                                          )}",
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12.sp,
                                          softWrap: true,
                                        ),
                                      ),
                                    ],
                                  ).paddingOnly(bottom: 6.h),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(IconAsset.locationIcon)
                                          .paddingOnly(right: 8.w),
                                      Expanded(
                                        child: CommonText(
                                          text: ((value.aptSuiteOther ?? "") +
                                              (value.address ?? '') +
                                              (value.country ?? "")),
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
                        ).paddingOnly(
                          left: 16.w,
                          right: 16.w,
                          top: (index == 0 &&
                                  (_profileController.isScrolling.value))
                              ? 70.h
                              : (index == 0)
                                  ? 15.h
                                  : 0.h,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }
      }
    });
  }

  Widget eventTabBar() {
    return TabBar(
      overlayColor: const MaterialStatePropertyAll(Colors.transparent),
      indicatorColor: Colors.white,
      controller: tabController,
      indicatorPadding: EdgeInsets.symmetric(horizontal: 17.w),
      // splashFactory: InkSplash.splashFactory,
      indicatorSize: TabBarIndicatorSize.tab,
      dividerColor: AppColors.backgroundColor,
      unselectedLabelColor: AppColors.textLightColor,
      unselectedLabelStyle: TextStyle(
          fontWeight: FontWeight.w400,
          color: AppColors.textLightColor,
          fontSize: 16.sp),
      labelStyle: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppColors.textColor,
          fontSize: 16.sp),
      padding: EdgeInsets.zero,
      onTap: (value) async {
        if (value == 0) {
          await _profileController.getEvent(eventStatus: EventStatus.APPROVAL);
        } else if (value == 1) {
          await _profileController.getEvent(eventStatus: EventStatus.PENDING);
        }
        _profileController.selectedIndex.value = value;
        print(
            "_profileController.selectedIndex.value ::${_profileController.selectedIndex.value}");
      },
      labelPadding: EdgeInsets.zero,
      tabs: [
        Tab(text: AppString.myEvent.tr),
        Tab(text: AppString.pendingEvent.tr),
      ],
    );
  }

  Widget commonText({required String text, Color? color}) {
    return CommonText(
      text: text,
      fontSize: 16.sp,
      color: color,
    );
  }
}

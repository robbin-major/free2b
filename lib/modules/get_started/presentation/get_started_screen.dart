import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_template/modules/authentication/controller/sign_in_controller.dart';
import 'package:flutter_template/modules/get_started/conteroller/get_started_controller.dart';
import 'package:flutter_template/utils/app_colors.dart';
import 'package:flutter_template/utils/app_string.dart';
import 'package:flutter_template/utils/assets.dart';
import 'package:flutter_template/utils/navigation_utils/navigation.dart';
import 'package:flutter_template/utils/navigation_utils/routes.dart';
import 'package:flutter_template/widget/common_text.dart';
import 'package:flutter_template/widget/custom_button.dart';
import 'package:get/get.dart';

import '../../../utils/common_service/app_pref_service.dart';

class GetStartedScreen extends StatefulWidget {
  final bool? isAnonymous;

  const GetStartedScreen({Key? key, this.isAnonymous}) : super(key: key);

  @override
  State<GetStartedScreen> createState() => _GetStartedScreenState();
}

class _GetStartedScreenState extends State<GetStartedScreen>
    with TickerProviderStateMixin {
  final GetStartedController _getStartedController =
      Get.put(GetStartedController());
  final SignInController signInController = Get.put(SignInController());

  @override
  void initState() {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
        systemNavigationBarColor: AppColors.backgroundColor));

    super.initState();
    _getStartedController.controller =
        BottomSheet.createAnimationController(this);

    _getStartedController.controller.duration =
        const Duration(milliseconds: 300);

    _getStartedController.controller.reverseDuration =
        const Duration(milliseconds: 300);

    _getStartedController.controller
        .drive(CurveTween(curve: Curves.fastOutSlowIn));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage(ImagesAsset.lestStarted),
                alignment: Alignment.topCenter,
              ),
            ),
            child: Stack(
              children: [
                Positioned(
                  top: -20,
                  child: RotatedBox(
                    quarterTurns: 2,
                    child: Container(
                      width: Get.width,
                      height: 110.h,
                      decoration: BoxDecoration(
                        color: Colors.yellow,
                        gradient: LinearGradient(
                          colors: [
                            Colors.black,
                            Colors.black.withOpacity(0.1),
                          ],
                          end: Alignment.topCenter,
                          begin: Alignment.bottomCenter,
                          stops: const [0, 50],
                        ),
                      ),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    (widget.isAnonymous ?? false)
                        ? Row(
                            children: [
                              const Spacer(),
                              GestureDetector(
                                onTap: () {
                                  log("widget.isAnonymous ${widget.isAnonymous}");
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
                                              margin:
                                                  EdgeInsets.only(top: 16.h),
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    BorderRadius.circular(5.r),
                                                color: AppColors
                                                    .disableButtonColor,
                                              ),
                                            ),
                                            CommonText(
                                              text: AppString.settings,
                                              fontSize: 18.sp,
                                              fontWeight: FontWeight.w500,
                                            ).paddingOnly(
                                                bottom: 24.h, top: 16.h),
                                            ListView.separated(
                                              shrinkWrap: true,
                                              separatorBuilder:
                                                  (context, index) {
                                                return Divider(
                                                        color: AppColors
                                                            .disableButtonColor)
                                                    .paddingSymmetric(
                                                        vertical: 3.h);
                                              },
                                              itemCount: _getStartedController
                                                  .settingList.length,
                                              itemBuilder: (context, index) {
                                                var data = _getStartedController
                                                    .settingList[index];
                                                return GestureDetector(
                                                  onTap: () {
                                                    index == 2
                                                        ? Navigation.replaceAll(
                                                            Routes.getStarted)
                                                        : SizedBox();
                                                  },
                                                  child: Container(
                                                    color: Colors.transparent,
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        data.endIcon,
                                                        CommonText(
                                                          text: data.text,
                                                          fontSize: 16.sp,
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          color: (index == 4)
                                                              ? AppColors
                                                                  .redColor
                                                              : AppColors
                                                                  .textColor,
                                                        ).paddingOnly(
                                                            left: 12.w),
                                                        const Spacer(),
                                                        data.startIcon,
                                                      ],
                                                    ).paddingSymmetric(
                                                        vertical: 3.h),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        ).paddingSymmetric(horizontal: 16.w),
                                      ).paddingOnly(bottom: 22.h);
                                    },
                                  ).whenComplete(() =>
                                      SystemChrome.setSystemUIOverlayStyle(
                                          SystemUiOverlayStyle(
                                        systemNavigationBarColor: AppColors
                                            .backgroundLightColor, // Set your desired color
                                      )));
                                },
                                child: Container(
                                  width: 32.w,
                                  height: 32.h,
                                  decoration: BoxDecoration(
                                      color: AppColors.backgroundLightColor,
                                      borderRadius:
                                          BorderRadius.circular(60.r)),
                                  child: Center(
                                    child: Icon(
                                      Icons.menu,
                                      size: 24.r,
                                      weight: 24.w,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ).paddingOnly(top: 50.h, left: 16.w, right: 16.w)
                        : Row(
                            children: [
                              CommonText(
                                text: _getStartedController
                                        .userCredential?.user?.displayName
                                        .toString() ??
                                    AppString.welcomeText,
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textColor,
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () {
                                  AppPrefService.setAnonymous(
                                      userToken: 'ANONYMOUS');
                                  Navigation.replaceAll(Routes.dashBoard);

                                  // log("widget.isAnonymous ${widget.isAnonymous}");
                                },
                                child: CommonText(
                                  text: AppString.skip,
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                ).paddingOnly(right: 2.w),
                              ),
                              SvgPicture.asset(
                                IconAsset.rightIcon,
                                fit: BoxFit.scaleDown,
                              ),
                            ],
                          ).paddingOnly(top: 50.h, left: 16.w, right: 16.w),
                    const Spacer(),
                    Obx(() => _getStartedController.isSheet.value
                        ? const SizedBox.shrink()
                        : Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Positioned(
                                bottom: 80.h,
                                child: Container(
                                  width: Get.width,
                                  height: 100.h,
                                  decoration: BoxDecoration(
                                    color: Colors.yellow,
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.black,
                                        Colors.black.withOpacity(0.1),
                                      ],
                                      end: Alignment.topCenter,
                                      begin: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                              ),
                              CommonText(
                                text: AppString.exploreAndEnjoyTheEvent,
                                fontWeight: FontWeight.w700,
                                fontSize: 32.sp,
                                softWrap: true,
                              ).paddingOnly(
                                left: 16.w,
                                right: 16.w,
                              ),
                            ],
                          )),
                    Obx(
                      () => _getStartedController.isSheet.value
                          ? const SizedBox.shrink()
                          : CommonText(
                              text: AppString.letsGetStartedDec,
                              fontSize: 14.sp,
                              color: AppColors.textLightColor,
                            ).paddingOnly(left: 16.w, right: 16.w, top: 12.h),
                    ),
                    CustomButton(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      endSvg: IconAsset.rightIcon,
                      text: AppString.letsGetStarted.tr,
                      onTap: () async {
                        _getStartedController.isSheet.value = true;
                        await showModalBottomSheet(
                          elevation: 0.0,
                          context: context,
                          isScrollControlled: false,
                          backgroundColor: Colors.transparent,
                          barrierColor:
                              AppColors.backgroundColor.withOpacity(0.6),
                          transitionAnimationController:
                              _getStartedController.controller,
                          builder: (context) {
                            return Container(
                              margin: EdgeInsets.all(12.sp),
                              width: Get.width,
                              decoration: BoxDecoration(
                                color: AppColors.backgroundLightColor,
                                image: const DecorationImage(
                                  image:
                                      AssetImage(ImagesAsset.backGroundImage),
                                  fit: BoxFit.fill,
                                ),
                                borderRadius: BorderRadius.circular(32.r),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          color: AppColors.yellowButtonColor,
                                          shape: BoxShape.circle,
                                        ),
                                        padding: EdgeInsets.symmetric(
                                            vertical: 16.h, horizontal: 11.w),
                                        child: SvgPicture.asset(
                                          IconAsset.appLogo2,
                                          fit: BoxFit.fill,
                                          // height: 56.h,
                                          // width: 56.w,
                                        ),
                                      ).paddingOnly(bottom: 12.h),
                                      const Spacer(),
                                      GestureDetector(
                                        onTap: () => Navigation.pop(),
                                        child: Icon(
                                          Icons.close_rounded,
                                          color: AppColors.textColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                  CommonText(
                                    text: AppString.getStarted.tr,
                                    fontSize: 25.sp,
                                    fontWeight: FontWeight.w600,
                                  ).paddingOnly(bottom: 8.h),
                                  CommonText(
                                    text: AppString.loginDec.tr,
                                    fontSize: 12.sp,
                                    color: AppColors.textLightColor,
                                  ).paddingOnly(bottom: 24.h),
                                  Obx(
                                    () => CustomButton(
                                      isLoader:
                                          signInController.isLoading.value,
                                      onTap: () async {
                                        print("CustomButton");
                                        // here to change for google
                                        await signInController.signIn();
                                      },
                                      margin: EdgeInsets.only(bottom: 16.h),
                                      text: AppString.continueWithGoogle.tr,
                                      buttonColor: AppColors.disableButtonColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16.sp,
                                      endSvg: IconAsset.rightIcon,
                                      svg: IconAsset.googleIcon,
                                    ),
                                  ),
                                  (Platform.isIOS)
                                      ? Obx(
                                          () => CustomButton(
                                            isLoader: signInController
                                                .isAppleLoading.value,
                                            onTap: () async =>
                                                await signInController
                                                    .signAppleIn(),
                                            text: AppString.continueWithApple,
                                            buttonColor:
                                                AppColors.disableButtonColor,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16.sp,
                                            endSvg: IconAsset.rightIcon,
                                            svg: IconAsset.appleIcon,
                                            // margin: EdgeInsets.only(bottom: 16.w),
                                          ),
                                        )
                                      : const SizedBox.shrink(),
                                ],
                              ).paddingOnly(
                                  top: 24.h,
                                  bottom: 24.h,
                                  left: 24.w,
                                  right: 24.w),
                            );
                          },
                        );
                        _getStartedController.isSheet.value = false;
                      },
                    ).paddingOnly(
                        right: 16.w, left: 16.w, bottom: 32.h, top: 32.h),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

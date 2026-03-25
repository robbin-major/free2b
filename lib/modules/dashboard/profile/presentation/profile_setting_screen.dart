import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_template/modules/dashboard/profile/controller/profile_controller.dart';
import 'package:flutter_template/modules/dashboard/profile/controller/profile_setting_controller.dart';
import 'package:flutter_template/utils/app_colors.dart';
import 'package:flutter_template/utils/app_string.dart';
import 'package:flutter_template/utils/assets.dart';
import 'package:flutter_template/utils/common_service/app_pref_service.dart';
import 'package:flutter_template/widget/appbar.dart';
import 'package:flutter_template/widget/common_text.dart';
import 'package:flutter_template/widget/custom_button.dart';
import 'package:flutter_template/widget/custom_loading_widget.dart';
import 'package:flutter_template/widget/custom_textfeild.dart';
import 'package:get/get.dart';

class ProfileSettingScreen extends StatelessWidget {
  ProfileSettingScreen({Key? key}) : super(key: key);

  final ProfileSettingController _profileController = Get.put(ProfileSettingController());

  final ProfileController _controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomAppBar(
        title: AppString.editProfile,
        color: AppColors.backgroundColor,
        centerTitle: false,
        leadingWidth: 25.w,
        leading: IconButton(
          onPressed: () {
            Get.back(result: "back");
          },
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: AppColors.textColor,
            // size: 2.5.h,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                _profileController.getImage();
              },
              child: SizedBox(
                height: Get.height * 0.2,
                width: Get.width,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    GetBuilder<ProfileSettingController>(
                      builder: (controller) {
                        return controller.addPictureGallery.value.path.isNotEmpty
                            ? Container(
                                height: 110.h,
                                width: 110.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    image: FileImage(
                                      controller.addPictureGallery.value,
                                    ),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                child: (controller.pictureGallery.value.isNotEmpty) ? const SizedBox.shrink() : const Icon(Icons.person),
                              )
                            : (controller.pictureGallery.value.isNotEmpty) ? CachedNetworkImage(
                                height: 110.h,
                                width: 110.w,
                                filterQuality: FilterQuality.low,
                                imageUrl: AppPrefService.getProfilePhoto(),
                                fit: BoxFit.cover,
                                imageBuilder: (context, imageProvider) => Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: (controller.pictureGallery.value.contains("https://"))
                                        ? DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: (controller.pictureGallery.value.isNotEmpty) ? const SizedBox.shrink() : const Icon(Icons.person),
                                ),
                                errorWidget: (context, url, error) {
                                  return (AppPrefService.getProfilePhoto().isNotEmpty) ? const SizedBox.shrink() : const Icon(Icons.person);
                                },
                                progressIndicatorBuilder: (context, url, progress) {
                                  return const CustomLoadingWidget();
                                },
                              ).paddingOnly(bottom: 8.h, top: 24.h) : Container(
                          height: 110.h,
                          width: 110.w,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red,
                              image: DecorationImage(
                                image: AssetImage(ImagesAsset.anonymous),
                              )),
                        ).paddingOnly(bottom: 8.h, top: 24.h);
                      },
                    ),
                    Positioned(
                      top: 80.h,
                      bottom: 0.h,
                      right: 115.w,
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 5.w),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundLightColor,
                          shape: BoxShape.circle,
                        ),
                        child: SvgPicture.asset(IconAsset.editIcon),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            CommonText(
              text: AppString.userDetails,
              fontWeight: FontWeight.w600,
              fontSize: 16.sp,
            ).paddingOnly(top: 16.h),
            CustomTextField(
              controller: _profileController.firstNameController,
              labelText: AppString.firstName,
              fillColor: AppColors.backgroundColor,
              labelStyle: TextStyle(
                color: AppColors.textColor,
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
              ),
              onChanged: (p0) {
                if (AppPrefService.getName().split(" ").first == p0) {
                  _profileController.isDisabledLoading.value = true;
                } else {
                  _profileController.isDisabledLoading.value = false;
                }
                _profileController.update();
              },
              radius: 4.r,
            ).paddingSymmetric(vertical: 24.h),
            CustomTextField(
              controller: _profileController.lastNameController,
              labelText: AppString.lastName,
              fillColor: AppColors.backgroundColor,
              radius: 4.r,
              labelStyle: TextStyle(
                color: AppColors.textColor,
                fontWeight: FontWeight.w600,
                fontSize: 12.sp,
              ),
              onChanged: (p0) {
                if (AppPrefService.getName().split(" ").last == p0) {
                  _profileController.isDisabledLoading.value = true;
                } else {
                  _profileController.isDisabledLoading.value = false;
                }
                _profileController.update();
              },
            ),
          ],
        ).paddingSymmetric(horizontal: 16.w),
      ),
      bottomNavigationBar: GetBuilder<ProfileSettingController>(builder: (controller) {
        return CustomButton(
          text: AppString.editProfile,
          height: Get.height * 0.06,
          margin: EdgeInsets.only(bottom: 16.h),
          isDisabled: controller.isDisabledLoading.value,
          isLoader: controller.isLoading.value,
          onTap: () async {
            await controller.updateUserData();
            _controller.isLoading.value = true;
          },
        ).paddingSymmetric(horizontal: 16.w);
      }),

    );
  }
}

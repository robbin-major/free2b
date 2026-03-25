// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/modules/dashboard/create_event/controller/create_event_controller.dart';
import 'package:flutter_template/modules/dashboard/create_event/widget/create_event_address.dart';
import 'package:flutter_template/modules/dashboard/create_event/widget/create_event_description.dart';
import 'package:flutter_template/utils/app_colors.dart';
import 'package:flutter_template/utils/app_string.dart';
import 'package:flutter_template/widget/appbar.dart';
import 'package:flutter_template/widget/common_text.dart';
import 'package:flutter_template/widget/custom_button.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../utils/navigation_utils/navigation.dart';
import '../../../../utils/utils.dart';
import '../../../../widget/app_snackbar.dart';
import '../widget/create_event_widget.dart';

class CreateEvent extends StatefulWidget {
  CreateEvent({Key? key}) : super(key: key);

  @override
  State<CreateEvent> createState() => _CreateEventState();
}

class _CreateEventState extends State<CreateEvent> with TickerProviderStateMixin {
  late PageController _pageViewController;

  late TabController _tabController;

  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(systemNavigationBarColor: AppColors.backgroundColor));
    _pageViewController = PageController();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    super.dispose();
    _pageViewController.dispose();
    _tabController.dispose();
  }

  final CreateEventController _createEventController = Get.put(CreateEventController());

  void _handlePageViewChanged(int currentPageIndex) {
    _tabController.index = currentPageIndex;
    setState(() {
      _currentPageIndex = currentPageIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      bottomNavigationBar: Obx(
        () => CustomButton(
          text: (_currentPageIndex == 2) ? AppString.submit : AppString.next,
          height: Get.height * 0.06,
          onTap: () async {
            print("dateTimeFormat.millisecondsSinceEpoch ${DateTime.now().millisecondsSinceEpoch}");
            if (_currentPageIndex == 0) {
              if (isDetailsValidate()) {
                _createEventController.eventChecker().then((value) {
                  print("then value ${value}");
                  if (value == false) {
                    _pageViewController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                    log("value false");
                  } else {
                    log("value true");
                    AppSnackBar.showErrorSnackBar(message: "Please Change Event Date.\nBecause This date Booked.", title: "Upload");
                    _createEventController.found.value = false;
                  }
                });
              } else {
                if (_createEventController.isShowSnackBar.value) {
                  AppSnackBar.showErrorSnackBar(message: "Please enter event details!", title: "Upload");
                  _createEventController.isShowSnackBar.value = false;
                  await Future.delayed(const Duration(seconds: 2));
                  _createEventController.isShowSnackBar.value = true;
                }
              }
            } else if (_currentPageIndex == 1) {
              print("_createEventController.descriptionController 01 ${_createEventController.descriptionController.length}");
              _createEventController.descriptionController.removeWhere(
                (element) => element.text.isEmpty,
              );
              if (!isDissCription()) {
                _createEventController.addTextField();
              }
              if (isDissCription()) {
                _pageViewController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                Utils.hideKeyboardInApp(context);
              }
            } else if (_currentPageIndex == 2) {
              if (!isDetailsValidate() && isValidateAddresPage()) {
                _pageViewController.jumpToPage(0);
              } else if (!isDissCription() && isValidateAddresPage()) {
                _pageViewController.jumpToPage(1);
              }
              if (isValidateAddresPage() && isDissCription() && isDetailsValidate()) {
                _createEventController.createEvent();
              } else {
                AppSnackBar.showErrorSnackBar(message: "Please enter event address!", title: "Upload");
              }
            }
          },
          // onTap: () {
          //   _createEventController.createEvent();
          // },
          isLoader: _createEventController.isLoader.value,
          margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
        ),
      ),
      appBar: CustomAppBar(
        title: AppString.accountSettings,
        color: AppColors.backgroundColor,
        centerTitle: false,
        leadingWidth: 25.w,
        automaticallyImplyLeading: true,
        leading: IconButton(
          onPressed: () {
            print("currentPageIndex ${_currentPageIndex}");
            if (_currentPageIndex == 0) {
              _createEventController.pictureGallery.value = '';
              Navigation.pop();
            } else {
              _pageViewController.previousPage(duration: Duration(seconds: 1), curve: Curves.ease);
            }
          },
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: AppColors.textColor,
            // size: 2.5.h,
          ),
        ),
      ),
      body: WillPopScope(
        onWillPop: () => Future(() => _createEventController.isLoader.value ? false : true),
        child: Column(
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: customLinearIndicator(
                    value: (_currentPageIndex == 0 || _currentPageIndex == 1 || _currentPageIndex == 2) ? 1 : 0,
                    color: Colors.white,
                  ).paddingSymmetric(horizontal: 2.w),
                ),
                Expanded(
                    child: customLinearIndicator(
                  value: (_currentPageIndex == 1 || _currentPageIndex == 2) ? 1 : 0,
                  color: (_currentPageIndex == 1 || _currentPageIndex == 2) ? AppColors.textColor : AppColors.linearColor,
                )),
                Expanded(
                  child: customLinearIndicator(
                    value: (_currentPageIndex == 2) ? 1 : 0,
                    color: (_currentPageIndex == 1 || _currentPageIndex == 2) ? AppColors.textColor : AppColors.linearColor,
                  ).paddingSymmetric(horizontal: 2.w),
                ),
              ],
            ).paddingSymmetric(horizontal: 16.w),
            CommonText(
              text: "${AppString.step.tr} ${_currentPageIndex + 1}/3",
              fontWeight: FontWeight.w600,
              fontSize: 14.sp,
              color: AppColors.textLightColor,
            ).paddingOnly(bottom: 32.h, top: 9.h),
            Expanded(
              child: PageView(
                physics: NeverScrollableScrollPhysics(),
                controller: _pageViewController,
                onPageChanged: _handlePageViewChanged,
                children: <Widget>[
                  CreateEventWidget().paddingOnly(top: 10.h),
                  const CreateEventDescription(),
                  CreateEventAddress(),
                ],
              ).paddingOnly(right: 16.w, left: 16.w),
            ),
          ],
        ),
      ),
    );
  }

  bool isDissCription() {
    return _createEventController.descriptionController.any((element) => element.text.isNotEmpty);
  }

  bool isValidateAddresPage() {
    return _createEventController.addressController.value.text.isNotEmpty &&
        _createEventController.zipCodeController.value.text.isNotEmpty &&
        _createEventController.cityController.value.text.isNotEmpty &&
        _createEventController.countryController.value.text.isNotEmpty &&
        _createEventController.selectedCategory.isNotEmpty &&
        _createEventController.categoryTypeController.value.text.isNotEmpty;
  }

  bool isDetailsValidate() {
    return _createEventController.titleController.text.isNotEmpty &&
        _createEventController.dateOfBirth.isNotEmpty &&
        _createEventController.timeToday.isNotEmpty &&
        _createEventController.pictureGallery.isNotEmpty;
  }

  Widget customLinearIndicator({double? value, Color? color}) {
    return LinearProgressIndicator(
      borderRadius: BorderRadius.circular(3.r),
      value: value,
      color: color,
    ).paddingSymmetric(horizontal: 2.w);
  }
}

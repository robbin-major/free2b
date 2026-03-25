// ignore_for_file: prefer_const_constructors

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

class CreateEventDescription extends StatefulWidget {
  const CreateEventDescription({Key? key}) : super(key: key);

  @override
  State<CreateEventDescription> createState() => _CreateEventDescriptionState();
}

class _CreateEventDescriptionState extends State<CreateEventDescription> {
  final CreateEventController _createEventController = Get.find();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Obx(
        () => Column(
          children: [
            // ListView(physics: NeverScrollableScrollPhysics(), shrinkWrap: true, children: _myPets),
            ListView.builder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: _createEventController.descriptionController.length,
              itemBuilder: (context, index) {
                return CustomTextField(
                        controller: _createEventController.descriptionController[index],
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        labelStyle: TextStyle(color: AppColors.textColor),
                        keyboardType: TextInputType.text,
                        maxLine: null,
                        fillColor: AppColors.backgroundColor,
                        labelText: AppString.description.tr,
                        hintText: AppString.enterEventDescriptionHere.tr,
                        textAlign: TextAlign.start,
                        suffix: index == 0
                            ? null
                            : GestureDetector(
                                onTap: () {
                                  _createEventController.removeTextField(index);
                                },
                                child: Icon(Icons.remove_circle)))
                    .paddingOnly(top: 10.h, bottom: 24.h);
              },
            ),

            GestureDetector(
              onTap: _createEventController.addTextField,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    IconAsset.plusIcon,
                    color: AppColors.yellowButtonColor,
                  ),
                  CommonText(
                    text: AppString.addDescription,
                    color: AppColors.yellowButtonColor,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w500,
                  ).paddingOnly(left: 12.w),
                ],
              ),
            ).paddingOnly(bottom: 24.h)
          ],
        ),
      ),
    );
  }
}

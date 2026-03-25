import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_template/utils/app_preferences.dart';
import 'package:get/get.dart';

import '../../../utils/app_string.dart';
import '../../../utils/assets.dart';
import '../../dashboard/profile/model/setting_model.dart';

class GetStartedController extends GetxController {
  UserCredential? userCredential;

  RxBool isSheet = false.obs;
  late AnimationController controller;

  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }

  RxList<SettingModel> settingList = <SettingModel>[
    SettingModel(
      endIcon: SvgPicture.asset(IconAsset.privacyIcon),
      text: AppString.privacyPolicy,
      startIcon: const Icon(CupertinoIcons.right_chevron),
    ),
    SettingModel(
      endIcon: SvgPicture.asset(IconAsset.termsConditionIcon),
      text: AppString.termsAndCondition,
      startIcon: const Icon(CupertinoIcons.right_chevron),
    ),
    SettingModel(
      endIcon: const Icon(Icons.login_outlined),
      text: AppString.login,
      startIcon: const SizedBox(),
    ),
  ].obs;
}

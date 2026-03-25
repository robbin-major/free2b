import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_template/modules/authentication/model/user_model.dart';
import 'package:flutter_template/modules/dashboard/home/home_service.dart';
import 'package:flutter_template/modules/dashboard/home/model/event_model.dart';
import 'package:flutter_template/modules/dashboard/profile/model/setting_model.dart';
import 'package:flutter_template/utils/app_preferences.dart';
import 'package:flutter_template/utils/app_string.dart';
import 'package:flutter_template/utils/assets.dart';
import 'package:flutter_template/utils/common_service/app_pref_service.dart';
import 'package:flutter_template/utils/enum/common_enums.dart';
import 'package:get/get.dart';

import '../../../../utils/remove_data/remove_data_service.dart';

class ProfileController extends GetxController {
  static ProfileController get to => Get.find();
  RxBool isScrolling = false.obs;
  RxBool isNotification = false.obs;
  RxBool isLogOutLoading = false.obs;
  RxBool isDeleteLoading = false.obs;
  RxBool isEventLoading = false.obs;
  RxBool isLoading = false.obs;
  RxList<EventModel> eventData = <EventModel>[].obs;
  RxString imageUrl = "".obs;
  RxInt selectedIndex = 0.obs;
  late final ScrollController scrollController;

  void _handlePositionAttach(ScrollPosition position) {
    scrollController.addListener(() {
      isScrolling.value = scrollController.position.minScrollExtent <
          scrollController.position.pixels;
    });
  }

  @override
  Future<void> onInit() async {
    scrollController = ScrollController(onAttach: _handlePositionAttach);
    await getEvent(eventStatus: EventStatus.APPROVAL);
    getUserData();
    super.onInit();
  }

  RxList<SettingModel> settingList = <SettingModel>[
    SettingModel(
      endIcon: SvgPicture.asset(IconAsset.profileSettingIcon),
      text: AppString.profileSettings,
      startIcon: const Icon(CupertinoIcons.right_chevron),
    ),
    SettingModel(
      endIcon: SvgPicture.asset(IconAsset.creditIcon),
      text: AppString.accountSettings,
      startIcon: const Icon(CupertinoIcons.right_chevron),
    ),
    SettingModel(
      endIcon: SvgPicture.asset(IconAsset.privacyIcon),
      text: AppString.privacyPolicy,
      startIcon: const Icon(CupertinoIcons.right_chevron),
    ),
    SettingModel(
      endIcon: Icon(Icons.language),
      text: AppString.language,
      startIcon: const Icon(CupertinoIcons.right_chevron),
    ),
    SettingModel(
      endIcon: SvgPicture.asset(IconAsset.termsConditionIcon),
      text: AppString.termsAndCondition,
      startIcon: const Icon(CupertinoIcons.right_chevron),
    ),
    SettingModel(
      endIcon: SvgPicture.asset(IconAsset.logoutIcon),
      text: AppString.logOut,
      startIcon: const SizedBox(),
    ),
  ].obs;

  Future<bool> signOutFromGoogle() async {
    isLogOutLoading.value = true;
    try {
      await FirebaseAuth.instance.signOut();
      return true;
    } on Exception catch (_) {
      isLogOutLoading.value = false;
      return false;
    } finally {
      isLogOutLoading.value = false;
    }
  }

  Future<bool> deleteAccount() async {
    isDeleteLoading.value = true;
    try {
      final String userId = AppPrefService.getUserUid();
      if (userId.isNotEmpty) {
        CollectionReference collectionRef =
            FirebaseFirestore.instance.collection('event');
        CollectionReference userCollection =
            FirebaseFirestore.instance.collection('users');
        QuerySnapshot querySnapshot =
            await collectionRef.where("uid", isEqualTo: userId).get();
        for (var element in querySnapshot.docs) {
          element.reference.delete();
        }
        DocumentSnapshot userQuerySnapshot =
            await userCollection.doc(userId).get();
        userQuerySnapshot.reference.delete();
        await FirebaseAuth.instance.currentUser?.delete();
        RemoveDataService.clearData();
      }
      return true;
    } on Exception catch (_) {
      isDeleteLoading.value = false;
      return false;
    } finally {
      isDeleteLoading.value = false;
    }
  }

  Rx<UserModel?> userData = UserModel().obs;

  Future getUserData() async {
    isLoading.value = true;
    userData.value = await HomeScreenService.getUserData();
    await AppPreference.setUser(userData.value);
    isLoading.value = false;
  }

  Future<void> getEvent({required EventStatus eventStatus}) async {
    try {
      isEventLoading.value = true;
      eventData.value =
          await HomeScreenService.getMyEventData(eventStatus: eventStatus);

      isEventLoading.value = false;
      update();
    } on Exception catch (e) {
      isEventLoading.value = false;
      update();
      log("Exception :: error : $e");
    } finally {
      isEventLoading.value = false;
    }
  }
}

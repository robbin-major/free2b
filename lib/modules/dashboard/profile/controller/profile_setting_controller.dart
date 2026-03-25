import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_template/modules/authentication/model/user_model.dart';
import 'package:flutter_template/modules/dashboard/profile/controller/profile_controller.dart';
import 'package:flutter_template/utils/app_preferences.dart';
import 'package:flutter_template/utils/common_service/app_pref_service.dart';
import 'package:flutter_template/utils/navigation_utils/navigation.dart';
import 'package:flutter_template/utils/social_authentication/google_auth.dart';
import 'package:flutter_template/utils/validation_utils.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProfileSettingController extends GetxController {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  Rx<File> addPictureGallery = File('').obs;
  RxString pictureGallery = "".obs;
  RxBool isLoading = false.obs;
  RxBool isDisabledLoading = true.obs;

  // Rx<int?> languageSelection = AppPreference.containsBaseOnKey("languageIndex") == false ? 0.obs : AppPreference.getInt("languageIndex").obs;
  Rx<int?> languageSelection = AppPreference.getInt("languageIndex") == null ? 0.obs : AppPreference.getInt("languageIndex").obs;

  @override
  void onInit() async {
    super.onInit();
    addUserData();
  }

  @override
  Future<void> dispose() async {
    await ProfileController.to.getUserData();
    super.dispose();
    clearUserData();
  }

  void addUserData() {
    firstNameController.text = AppPrefService.getName().split(" ").first;
    lastNameController.text = AppPrefService.getName().split(" ").sublist(1).toString().replaceAll('[', "").replaceAll(']', "").replaceAll(',', "");
    pictureGallery.value = AppPrefService.getProfilePhoto();
    update();
  }

  void clearUserData() {
    firstNameController.clear();
    lastNameController.clear();
    pictureGallery.value = '';
    update();
  }

  Future updateUserData() async {
    if (lastNameController.text.isValidFirstName() || firstNameController.text.isValidLastName()) {
      isLoading.value = true;
      update();
      UserModel user = UserModel();
      user.firstName = firstNameController.text;
      try {
        await uploadImage();
        update();
        await GoogleSignInAuth.userUpdate(
          uid: AppPrefService.getUserUid(),
          userModel: UserModel(
            email: AppPrefService.getEmail(),
            firstName: (firstNameController.text == AppPrefService.getName().split(" ").first)
                ? AppPrefService.getName().split(" ").first
                : firstNameController.text,
            lastName: (lastNameController.text == AppPrefService.getName().split(" ").last)
                ? AppPrefService.getName().split(" ").last
                : lastNameController.text,
            profilePhoto:  pictureGallery.value,
          ),
        ).then((value) async {
          AppPrefService.setEmail(userEmail: AppPrefService.getEmail());
          AppPrefService.setName(userName: ("${firstNameController.text} ${lastNameController.text}"));
          AppPrefService.setProfilePhoto(userProfilePhoto: (pictureGallery.value));
          await ProfileController.to.getUserData();

          Navigation.pop();

          update();
        });
        update();
      } on Exception catch (e) {
        print("Exception :: $e");
      } finally {
        isLoading.value = false;
        update();
      }
    }
  }

  void getImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      update();
      await picker.pickImage(source: ImageSource.gallery).then((value) {
        if (value != null) {
          pictureGallery.value = value.path.toString();
          addPictureGallery.value = File(pictureGallery.value);
          isDisabledLoading.value = false;
        }
        update();
      });
      update();
    } catch (e) {
      // AppSnackBar.show("Pick File", e);
    }
  }

  Future uploadImage() async {
    String fileName = addPictureGallery.value.path.split("/").last;

    Reference ref = FirebaseStorage.instance.ref().child('event').child(fileName);

    try {
      UploadTask uploadTask = ref.putFile(addPictureGallery.value);
        pictureGallery.value = await (await uploadTask).ref.getDownloadURL();
    } catch (e) {
      print("uploadImage :: error : $e");
    }
  }
}

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_template/modules/authentication/model/user_model.dart';
import 'package:flutter_template/modules/dashboard/home/home_service.dart';
import 'package:flutter_template/utils/common_service/app_pref_service.dart';
import 'package:flutter_template/utils/navigation_utils/navigation.dart';
import 'package:flutter_template/utils/navigation_utils/routes.dart';
import 'package:flutter_template/utils/social_authentication/apple_auth.dart';
import 'package:flutter_template/utils/social_authentication/google_auth.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../utils/app_preferences.dart';

class SignInController extends GetxController {
  GoogleSignIn googleSignIn = GoogleSignIn();
  RxBool isLoading = false.obs;
  RxBool isAppleLoading = false.obs;
  final TextEditingController controller = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  FocusNode phoneTextFieldFocusNode = FocusNode();
  RxBool isDisable = true.obs;
  RxBool isEmail = true.obs;
  final ValueNotifier<Country?> selectedDialogCountry =
      ValueNotifier(CountryPickerUtils.getCountryByPhoneCode('91'));

  Future<void> signIn() async {
    try {
      isLoading.value = true;
      var value = await GoogleSignInAuth.signInWithGoogle();
      print("value ${value?.uid}");
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(value?.uid)
          .get();

      if (documentSnapshot.exists) {
        if (value != null) {
          AppPrefService.setUserUid(userToken: (value.uid));
          AppPrefService.setEmail(userEmail: (value.email ?? ''));
          AppPrefService.setName(userName: (value.displayName ?? ''));
          AppPrefService.setProfilePhoto(
              userProfilePhoto: (value.photoURL ?? ''));
          try {
            UserModel userModel = UserModel(
              email: value.email,
              profilePhoto: value.photoURL,
              firstName: value.displayName?.split(" ").first,
              lastName: value.displayName?.split(" ").last,
            );
          } catch (e) {
            print("GoogleSignInAuth : createUser :: error : $e");
          }
          Navigation.replaceAll(Routes.dashBoard);
          AppPreference.clearBaseOnKey("anonymous");
        }
      } else {
        UserModel userModel = UserModel(
          email: value?.email ?? "",
          profilePhoto: value?.photoURL ?? "",
          firstName: value?.displayName?.split(" ").first ?? "",
          lastName: value?.displayName?.split(" ").last ?? "",
        );
        await GoogleSignInAuth.createUser(
            uid: value?.uid ?? '', userModel: userModel);
        await AppPrefService.setUserUid(userToken: (value?.uid ?? ''));
        await HomeScreenService.getUserData();
        Navigation.replaceAll(Routes.dashBoard);
        AppPreference.clearBaseOnKey("anonymous");
      }
      isLoading.value = false;
    } catch (e, st) {
      print("signIn error $e $st");
      isLoading.value = false;
    } finally {
      if (FirebaseAuth.instance.currentUser != null) {
        await googleSignIn.signOut();
        await FirebaseAuth.instance.signOut();
      }

      if (isLoading.value) isLoading.value = false;
    }
  }

//   Future<void> signIn1() async {
//     try {
//       isLoading.value = true;
//       var value = await GoogleSignInAuth.signInWithGoogle();
//       isLoading.value = false;
// print('value :: ${value?.displayName}');
//       if (value != null) {
//         AppPrefService.setUserUid(userToken: (value.uid ?? ''));
//         AppPrefService.setEmail(userEmail: (value.email ?? ''));
//         AppPrefService.setName(userName: (value.displayName ?? ''));
//         AppPrefService.setProfilePhoto(userProfilePhoto: (value.photoURL ?? ''));
//         try {
//           UserModel userModel = UserModel(
//             email: value.email,
//             profilePhoto: value.photoURL,
//             firstName: value.displayName?.split(" ").first,
//             lastName: value.displayName?.split(" ").last,
//           );
//           await GoogleSignInAuth.createUser(uid: value.uid, userModel: userModel);
//         } catch (e) {
//           print("GoogleSignInAuth : createUser :: error : $e");
//         }
//         Navigation.replaceAll(Routes.dashBoard);
//       }
//     } catch (e) {
//       print("signIn error $e");
//       isLoading.value = false;
//     } finally {
//       if (isLoading.value) isLoading.value = false;
//     }
//   }

  Future<void> signAppleIn() async {
    try {
      isAppleLoading.value = true;
      var value = await AppleSignInAuth.signInWithApple();
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(value?.uid)
          .get();
      if (!documentSnapshot.exists) {
        if (value != null) {
          AppPrefService.setUserUid(userToken: (value.uid));
          AppPrefService.setEmail(userEmail: (value.email ?? ''));
          AppPrefService.setName(userName: (value.displayName ?? ''));
          AppPrefService.setProfilePhoto(
              userProfilePhoto: (value.photoURL ?? ''));
          try {
            UserModel userModel = UserModel(
              email: value.email,
              profilePhoto: value.photoURL,
              firstName: value.displayName?.split(" ").first,
              lastName: value.displayName?.split(" ").last,
            );
            await GoogleSignInAuth.createUser(
                uid: value.uid, userModel: userModel);
          } catch (e) {
            print("GoogleSignInAuth : createUser :: error : $e");
          }
          Navigation.replaceAll(Routes.dashBoard);
        }
      } else {
        await AppPrefService.setUserUid(userToken: (value?.uid ?? ''));
        await HomeScreenService.getUserData();
        Navigation.replaceAll(Routes.dashBoard);
      }
      isAppleLoading.value = false;
    } catch (e, st) {
      print("signIn error $e $st");
      isAppleLoading.value = false;
    } finally {
      if (isAppleLoading.value) isAppleLoading.value = false;
    }
  }

  void handleButtonDisable() {
    isDisable.value = (controller.text == "" || controller.text.isEmpty) ||
        (passwordController.text == "" || passwordController.text.isEmpty);
  }
}

import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_pickers/country.dart';
import 'package:country_pickers/country_pickers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_template/modules/authentication/model/user_model.dart';
import 'package:flutter_template/modules/dashboard/home/home_service.dart';
import 'package:flutter_template/utils/auth_session_service.dart';
import 'package:flutter_template/utils/common_service/app_pref_service.dart';
import 'package:flutter_template/utils/navigation_utils/navigation.dart';
import 'package:flutter_template/utils/navigation_utils/routes.dart';
import 'package:flutter_template/utils/social_authentication/apple_auth.dart';
import 'package:flutter_template/utils/social_authentication/google_auth.dart';
import 'package:flutter_template/widget/app_snackbar.dart';
import 'package:get/get.dart';

import '../../../utils/app_preferences.dart';

class SignInController extends GetxController {
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
      if (value == null) {
        print(
          'Google sign-in did not complete. Check logcat for '
          'GoogleSignInAuth PlatformException/FirebaseAuthException details.',
        );
        AppSnackBar.showErrorSnackBar(
          message: GoogleSignInAuth.lastErrorMessage ??
              'Google sign-in could not start. Please try again.',
          title: 'Error',
        );
        isLoading.value = false;
        return;
      }
      print("value ${value.uid}");
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(value.uid)
          .get();

      if (documentSnapshot.exists) {
        AppPrefService.setUserUid(userToken: value.uid);
        AppPrefService.setEmail(userEmail: value.email ?? '');
        AppPrefService.setName(userName: value.displayName ?? '');
        AppPrefService.setProfilePhoto(
            userProfilePhoto: value.photoURL ?? '');
        await AuthSessionService.syncCurrentUserToPrefs();
        _openDashboardAfterSignIn();
        AppPreference.clearBaseOnKey("anonymous");
      } else {
        UserModel userModel = UserModel(
          email: value.email ?? "",
          profilePhoto: value.photoURL ?? "",
          firstName: value.displayName?.split(" ").first ?? "",
          lastName: value.displayName?.split(" ").last ?? "",
        );
        await GoogleSignInAuth.createUser(
            uid: value.uid, userModel: userModel);
        await AppPrefService.setUserUid(userToken: value.uid);
        await HomeScreenService.getUserData();
        await AuthSessionService.syncCurrentUserToPrefs();
        _openDashboardAfterSignIn();
        AppPreference.clearBaseOnKey("anonymous");
      }
      isLoading.value = false;
    } catch (e, st) {
      print("signIn error $e $st");
      isLoading.value = false;
    } finally {
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
      if (value == null) {
        isAppleLoading.value = false;
        return;
      }
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(value.uid)
          .get();
      if (!documentSnapshot.exists) {
        AppPrefService.setUserUid(userToken: value.uid);
        AppPrefService.setEmail(userEmail: value.email ?? '');
        AppPrefService.setName(userName: value.displayName ?? '');
        AppPrefService.setProfilePhoto(
            userProfilePhoto: value.photoURL ?? '');
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
        await AuthSessionService.syncCurrentUserToPrefs();
        _openDashboardAfterSignIn();
      } else {
        await AppPrefService.setUserUid(userToken: value.uid);
        await HomeScreenService.getUserData();
        await AuthSessionService.syncCurrentUserToPrefs();
        _openDashboardAfterSignIn();
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

  void _openDashboardAfterSignIn() {
    final Object? arguments = Get.arguments;
    final int returnTab = arguments is Map && arguments['returnTab'] is int
        ? arguments['returnTab'] as int
        : 0;

    Navigation.replaceAll(
      Routes.dashBoard,
      arg: {'initialIndex': returnTab},
    );
  }
}

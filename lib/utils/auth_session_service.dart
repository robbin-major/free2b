import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_template/modules/authentication/model/user_model.dart';
import 'package:flutter_template/utils/app_preferences.dart';
import 'package:flutter_template/utils/common_service/app_pref_service.dart';

class AuthSessionService {
  static User? get currentUser => FirebaseAuth.instance.currentUser;

  static bool get isSignedIn => currentUser != null;

  static String get userId => currentUser?.uid ?? AppPrefService.getUserUid();

  static Future<UserModel?> syncCurrentUserToPrefs() async {
    final User? user = currentUser;
    if (user == null) {
      return null;
    }

    await AppPrefService.setUserUid(userToken: user.uid);
    await AppPrefService.setEmail(userEmail: user.email ?? '');
    await AppPrefService.setName(userName: user.displayName ?? '');
    await AppPrefService.setProfilePhoto(userProfilePhoto: user.photoURL ?? '');
    AppPreference.clearBaseOnKey(AppPrefService.anonymous);

    try {
      final DocumentSnapshot userData = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final Object? data = userData.data();
      if (data is Map<String, dynamic>) {
        final UserModel userModel = UserModel.fromJson(data);
        await AppPrefService.setEmail(
          userEmail: userModel.email ?? user.email ?? '',
        );
        await AppPrefService.setName(
          userName: '${userModel.firstName ?? ''} ${userModel.lastName ?? ''}'
              .trim(),
        );
        await AppPrefService.setProfilePhoto(
          userProfilePhoto: userModel.profilePhoto ?? user.photoURL ?? '',
        );
        await AppPreference.setUser(userModel);
        return userModel;
      }
    } catch (error) {
      print('AuthSessionService sync user error: $error');
    }

    return null;
  }
}

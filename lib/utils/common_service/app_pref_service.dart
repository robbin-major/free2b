import 'package:flutter_template/utils/app_preferences.dart';

class AppPrefService {
  static const userUid = "user_Uid";
  static const anonymous = "anonymous";
  static const userEmailKey = "user_email";
  static const userNameKey = "userNameKey";
  static const userPhoto = "userPhoto";

  static clearAppPreferences() {
    return AppPreference.clearSharedPreferences();
  }

  static Future<void> setAnonymous({required String userToken}) {
    return AppPreference.setString(anonymous, userToken);
  }

  static String getAnonymous() {
    return AppPreference.getString(anonymous);
  }

  static Future<void> setUserUid({required String userToken}) {
    return AppPreference.setString(userUid, userToken);
  }

  static String getUserUid() {
    return AppPreference.getString(userUid);
  }

  static Future<void> setEmail({required String userEmail}) {
    return AppPreference.setString(userEmailKey, userEmail);
  }

  static String getEmail() {
    return AppPreference.getString(userEmailKey);
  }

  static Future<void> setName({required String userName}) {
    return AppPreference.setString(userNameKey, userName);
  }

  static String getName() {
    return AppPreference.getString(userNameKey);
  }

  static Future<void> setProfilePhoto({required String userProfilePhoto}) {
    return AppPreference.setString(userPhoto, userProfilePhoto);
  }

  static String getProfilePhoto() {
    return AppPreference.getString(userPhoto);
  }
}

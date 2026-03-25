import 'package:flutter_template/utils/app_preferences.dart';

class RemoveDataService {
  static clearData() {
    AppPreference.clearBaseOnKey("keyUser");
    AppPreference.clearBaseOnKey("keyToken");
    AppPreference.clearBaseOnKey("user_Uid");
    AppPreference.clearBaseOnKey("anonymous");
    AppPreference.clearBaseOnKey("user_email");
    AppPreference.clearBaseOnKey("userNameKey");
    AppPreference.clearBaseOnKey("userPhoto");

  }
}

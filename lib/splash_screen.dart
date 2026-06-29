import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_template/utils/app_preferences.dart';
import 'package:flutter_template/utils/auth_session_service.dart';
import 'package:flutter_template/utils/assets.dart';
import 'package:flutter_template/utils/common_service/app_pref_service.dart';
import 'package:flutter_template/utils/navigation_utils/navigation.dart';
import 'package:flutter_template/utils/navigation_utils/routes.dart';
import 'package:flutter_template/utils/size_utils.dart';
import 'package:flutter_template/utils/utils.dart';
import 'package:get/get.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(
      const Duration(seconds: 3),
      () {
        navigateFurther(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    SizeUtils().init(context);
    return SafeArea(
      child: Center(
        child: Container(
          height: Get.height,
          width: Get.width,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                ImagesAsset.splashImage,
              ),
              fit: BoxFit.fill,
            ),
          ),
          child: Image.asset(
            "assets/icon/app_logo.png",
            fit: BoxFit.scaleDown,
            // width: Get.width,
          ),
        ),
      ),
    );
  }

  Future<void> navigateFurther(BuildContext context) async {
    final int? languageIndex = AppPreference.getInt("languageIndex");
    if (languageIndex == null) {
      Navigation.replaceAll(Routes.languageSetting);
      return;
    }

    languageIndex == 0
        ? Utils.updateLanguage(const Locale('en', 'US'))
        : Utils.updateLanguage(const Locale('es', 'ES'));

    if (AuthSessionService.isSignedIn) {
      await AuthSessionService.syncCurrentUserToPrefs();
      Navigation.replaceAll(Routes.dashBoard);
      return;
    }

    if (AppPrefService.getAnonymous().isNotEmpty) {
      Navigation.replaceAll(Routes.dashBoard);
      return;
    }

    Navigation.replaceAll(Routes.getStarted);
  }
}

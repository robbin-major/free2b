import 'package:flutter_template/modules/dashboard/create_event/presentation/create_event.dart';
import 'package:flutter_template/modules/dashboard/dash_board/presentation/dash_board.dart';
import 'package:flutter_template/modules/dashboard/home/presentation/details_screen.dart';
import 'package:flutter_template/modules/dashboard/home/presentation/home_screen.dart';
import 'package:flutter_template/modules/dashboard/profile/presentation/account_setting.dart';
import 'package:flutter_template/modules/dashboard/profile/presentation/language_screen.dart';
import 'package:flutter_template/modules/dashboard/profile/presentation/profile_setting_screen.dart';
import 'package:flutter_template/modules/get_started/presentation/get_started_screen.dart';
import 'package:flutter_template/splash_screen.dart';
import 'package:get/get.dart';

mixin Routes {
  static const defaultTransition = Transition.rightToLeft;

  // get started
  static const String splash = '/splash';
  static const String homeScreen = '/home';
  static const String dashBoard = '/dashBoard';
  static const String detailsScreen = '/detailsScreen';
  static const String getStarted = '/getStarted';
  static const String accountSetting = '/accountSetting';
  static const String createEvent = '/createEvent';
  static const String profileSettingScreen = '/ProfileSettingScreen';
  static const String dynamicTextFieldList = '/DynamicTextFieldList';
  static const String languageSetting = '/LanguageSetting';

  static List<GetPage<dynamic>> pages = [
    GetPage<dynamic>(
      name: splash,
      page: () => const SplashScreen(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: getStarted,
      page: () => GetStartedScreen(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: accountSetting,
      page: () => AccountSetting(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: createEvent,
      page: () => CreateEvent(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: homeScreen,
      page: () => HomeScreen(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: languageSetting,
      page: () => const LanguageSetting(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: detailsScreen,
      page: () => DetailsScreen(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: dashBoard,
      page: () => DashBoard(),
      transition: defaultTransition,
    ),
    GetPage<dynamic>(
      name: profileSettingScreen,
      page: () => ProfileSettingScreen(),
      transition: defaultTransition,
    ),
    /*GetPage<dynamic>(
      name: dynamicTextFieldList,
      page: () => DynamicTextFieldList(),
      transition: defaultTransition,
    ),*/
  ];
}

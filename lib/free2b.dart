import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/generated/l10n.dart';
import 'package:flutter_template/language_change_provider.dart';
import 'package:flutter_template/utils/app_colors.dart';
import 'package:flutter_template/utils/app_string.dart';
import 'package:flutter_template/utils/navigation_utils/routes.dart';
import 'package:flutter_template/utils/utils.dart';
import 'package:get/get.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(375, 812),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, child) {
          return GetMaterialApp(
            translations: Languages(),
            locale: Get.deviceLocale,
            fallbackLocale: const Locale('en', 'US'),
            debugShowCheckedModeBanner: false,
            localizationsDelegates: const [
              S.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            theme: ThemeData(
              useMaterial3: false,
              scaffoldBackgroundColor: AppColors.backgroundColor,
              fontFamily: "InstrumentSans",
              iconTheme: const IconThemeData(color: Colors.white),
              appBarTheme: AppBarTheme(
                backgroundColor: AppColors.backgroundColor,
                scrolledUnderElevation: 0,
                iconTheme: IconThemeData(color: AppColors.backgroundColor),
                foregroundColor: AppColors.backgroundColor,
              ),
            ),
            themeMode: ThemeMode.dark,
            darkTheme: ThemeData.dark(),
            title: AppString.appName,
            initialBinding: AppBidding(),
            initialRoute: Routes.splash,
            // initialRoute: Routes.aDemo,
            getPages: Routes.pages,
            builder: (context, child) {
              return Scaffold(
                body: GestureDetector(
                  onTap: () {
                    Utils.hideKeyboardInApp(context);
                  },
                  child: child,
                ),
              );
            },
          );
        });
  }
}

class AppBidding extends Bindings {
  @override
  void dependencies() {}
}

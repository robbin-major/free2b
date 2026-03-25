import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_template/firebase_options.dart';
import 'package:flutter_template/free2b.dart';
import 'package:flutter_template/utils/app_colors.dart';
import 'package:flutter_template/utils/app_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/standalone.dart' as tz;

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.backgroundColor,
    ),
  );
  // await Firebase.initializeApp();
  // await FireBaseNotification().setUpLocalNotification();
  // FirebaseAnalyticsUtils().init();
  // FirebaseCrashlytics crashlytics = FirebaseCrashlytics.instance;
  runZonedGuarded<Future<void>>(() async {
    // await crashlytics.setCrashlyticsCollectionEnabled(true);
    // FlutterError.onError = crashlytics.recordFlutterError;
    await AppPreference.initMySharedPreferences();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
  }, (error, stack) => print(error));

  runApp(MyApp());
  // crashlytics.recordError(error, stack));
}



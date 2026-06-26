import 'dart:async';
import 'dart:ui';

import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_template/firebase_options.dart';
import 'package:flutter_template/free2b.dart';
import 'package:flutter_template/utils/app_colors.dart';
import 'package:flutter_template/utils/app_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.backgroundColor,
    ),
  );

  var crashlyticsReady = false;

  await runZonedGuarded<Future<void>>(() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      crashlyticsReady = true;

      FlutterError.onError = (FlutterErrorDetails details) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      };

      PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };

      await AppPreference.initMySharedPreferences();
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      runApp(const MyApp());
    } catch (error, stack) {
      debugPrint('Free2B startup failed: $error');
      if (crashlyticsReady) {
        await FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      }
      runApp(const StartupFallbackApp());
    }
  }, (error, stack) {
    debugPrint('Free2B uncaught error: $error');
    if (crashlyticsReady) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    }
  });
}

class StartupFallbackApp extends StatelessWidget {
  const StartupFallbackApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: AppColors.backgroundColor,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Free2B',
                  style: TextStyle(
                    color: AppColors.yellowButtonColor,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'We had trouble starting the app. Please close Free2B and try again.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

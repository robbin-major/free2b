import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_template/splash_screen.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class Utils {
  static void hideKeyboardInApp(BuildContext context) {
    var currentFocus = FocusScope.of(context);
    if (!currentFocus.hasPrimaryFocus && currentFocus.focusedChild != null) {
      FocusManager.instance.primaryFocus!.unfocus();
    }
  }

  static String getFormattedDate({required String format, required String date}) {
    DateFormat inputFormat = DateFormat("dd-MM-yyyy hh:mm a");

    DateTime? parsedDateTime = inputFormat.tryParse(date);
    if (parsedDateTime == null) {
      parsedDateTime = DateFormat("dd-MM-yyyy").tryParse(date);
    }
    DateFormat dateFormat = DateFormat(format);
    String formattedDate = dateFormat.format(parsedDateTime!);
    return formattedDate;
  }

  static String getDateTime({required String date, required String format}) {
    DateFormat inputFormat = DateFormat("dd-MM-yyyy hh:mm a");
    DateTime? parsedDateTime = inputFormat.tryParse(date);
    if (parsedDateTime == null) {
      parsedDateTime = DateFormat("dd-MM-yyyy").tryParse(date);
    }
    DateFormat timeFormat = DateFormat(format);
    String formattedTime = timeFormat.format(parsedDateTime!);
    return formattedTime;
  }

  // static DateTime millisecondsToDate({required String date}) {
  //   return DateTime.fromMillisecondsSinceEpoch(int.tryParse(date) ?? 0,
  //       isUtc: false);
  // }

  static final List locale = [
    {'name': 'English', 'locale': const Locale('en', 'US')},
    {'name': 'Spanish', 'locale': const Locale('es', 'ES')},
  ];

  static updateLanguage(
    Locale locale,
  ) {
    Get.updateLocale(locale);
  }
}

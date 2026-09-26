import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/modules/authentication/model/user_model.dart';
import 'package:flutter_template/modules/dashboard/home/home_service.dart';
import 'package:flutter_template/modules/dashboard/home/model/event_model.dart';
import 'package:flutter_template/utils/app_preferences.dart';
import 'package:flutter_template/utils/common_service/app_pref_service.dart';
import 'package:flutter_template/utils/event_maps.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../utils/app_colors.dart';

class DetailController extends GetxController {
  RxBool isBookMark = false.obs;
  EventModel eventModel = EventModel();
  Rx<UserModel?> userData = Rx<UserModel?>(null);
  RxList<String> bookMarkId = <String>[].obs;
  RxList<String> attendingId = <String>[].obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    if (Get.arguments != null) {
      eventModel = Get.arguments;
    }
    getUserData();
    super.onInit();
  }

  Future<void> getUserData() async {
    final String userID = AppPrefService.getUserUid();
    if (userID.isNotEmpty) {
      bookMarkId.clear();
      userData.value = await HomeScreenService.getUserData();

      bookMarkId.addAll(userData.value?.bookmark ?? []);
      attendingId
        ..clear()
        ..addAll(userData.value?.attending ?? []);
      print("getUserData bookMarkId ${bookMarkId.length}");
      await AppPreference.setUser(userData.value);
    }
  }

  Future<void> eventBookMark() async {
    try {
      isLoading.value = true;
      await HomeScreenService.eventBookmark(bookmarkList: bookMarkId);
      await getUserData();
      isLoading.value = false;
    } catch (error) {
      isLoading.value = false;
      rethrow;
    }
  }

  Future<void> eventAttendance({
    required String eventId,
    required bool attending,
  }) async {
    try {
      isLoading.value = true;
      await HomeScreenService.eventAttendance(
        eventId: eventId,
        attending: attending,
      );
      await getUserData();
      isLoading.value = false;
    } catch (error) {
      isLoading.value = false;
      rethrow;
    }
  }

  Future<void> openEventMap(EventModel event) async {
    final String destination = eventMapDestination(
      event,
      fallbackLatitude: event.latitude,
      fallbackLongitude: event.longitude,
    );
    if (destination.isEmpty) return;

    await launchUrl(
      googleMapsSearchUri(
        event,
        fallbackLatitude: event.latitude,
        fallbackLongitude: event.longitude,
      ),
      mode: LaunchMode.externalApplication,
    );
  }

  final RegExp _linkRegExp = RegExp(
    r'(https?:\/\/[^\s]+)',
    caseSensitive: false,
  );

  List<TextSpan> getStyledText({required String text}) {
    final List<TextSpan> spans = [];
    final matches = _linkRegExp.allMatches(text);
    int lastIndex = 0;

    for (var match in matches) {
      if (match.start > lastIndex) {
        spans.add(TextSpan(
          text: text.substring(lastIndex, match.start),
          style: TextStyle(color: AppColors.textLightColor, fontSize: 14.sp, fontWeight: FontWeight.w500),
        ));
      }
      spans.add(
        TextSpan(
          text: match.group(0),
          style: TextStyle(color: Colors.blue),
          recognizer: TapGestureRecognizer()
            ..onTap = () {
              _launchURL(match.group(0)!);
            },
        ),
      );
      lastIndex = match.end;
    }

    if (lastIndex < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastIndex),
        style: TextStyle(color: AppColors.textLightColor, fontSize: 14.sp, fontWeight: FontWeight.w500),
      ));
    }

    return spans;
  }

  void _launchURL(String url) async {
    final Uri _url = Uri.parse(url);

    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }
}

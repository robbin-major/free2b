import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/modules/authentication/model/user_model.dart';
import 'package:flutter_template/modules/dashboard/home/home_service.dart';
import 'package:flutter_template/modules/dashboard/home/model/event_model.dart';
import 'package:flutter_template/utils/app_preferences.dart';
import 'package:flutter_template/utils/common_service/app_pref_service.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geocoding/geocoding.dart';

import '../../../../utils/app_colors.dart';

class DetailController extends GetxController {
  RxBool isBookMark = false.obs;
  EventModel eventModel = EventModel();
  Rx<UserModel?> userData = UserModel().obs;
  RxList<String> bookMarkId = <String>[].obs;
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

  Future<void> getLatLngFromAddress(String address) async {
    RxString locationMessage = "".obs;
    try {
      List<Location> locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        final location = locations.first;
        locationMessage.value = "Latitude: ${location.latitude}, Longitude: ${location.longitude}";
        print("locationMessage ${locationMessage.value}");
        if (locationMessage.isNotEmpty) openMap(location.latitude, location.longitude);
      } else {
        locationMessage.value = "No location found for the given address.";
      }
    } catch (e) {
      locationMessage.value = "Error occurred: $e";
    }
  }

  Future<void> openMap(double latitude, double longitude) async {
    String googleUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (googleUrl.isNotEmpty) {
      print(googleUrl);
      await launchUrl(Uri.parse(googleUrl));
    } else {
      throw 'Could not open the map.';
    }
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

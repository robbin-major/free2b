import 'package:flutter_template/modules/dashboard/bookmark/service/book_mark_service.dart';
import 'package:flutter_template/modules/dashboard/home/home_service.dart';
import 'package:flutter_template/modules/dashboard/home/model/event_model.dart';
import 'package:flutter_template/utils/auth_session_service.dart';
import 'package:flutter_template/utils/constants.dart';
import 'package:flutter_template/utils/event_date_utils.dart';
import 'package:get/get.dart';

import '../../../../utils/utils.dart';

class BookMarkController extends GetxController {
  RxList<EventModel> bookMarkEvent = <EventModel>[].obs;
  RxBool isBookMarkLoading = false.obs;

  Future<void> getBookMark() async {
    try {
      if (Constants.isBookmarkLoading.value) {
        isBookMarkLoading.value = true;
      }
      await AuthSessionService.syncCurrentUserToPrefs();
      final String userID = AuthSessionService.userId;
      await HomeScreenService.getUserData();
      print("userID 00 ${userID}");
      if (userID.isNotEmpty) {
        print("userID 02 ${userID}");
        bookMarkEvent.value = await BookMarkService.getBookmarkEvent();
        print("bookMarkEvent.value ${bookMarkEvent.length}");
      }
      bookMarkEvent
          .removeWhere((element) {
        final DateTime? eventDate =
            EventDateUtils.parseEventDateTime(element.startDate);
        final DateTime today = DateTime.now();
        final DateTime todayStart =
            DateTime(today.year, today.month, today.day);
        final bool isPastEvent = eventDate != null &&
            DateTime(eventDate.year, eventDate.month, eventDate.day)
                .isBefore(todayStart);

        return ((element.startDate?.isEmpty ?? true) ||
            element.startDate == " " ||
            element.startDate == "Invalid date  undefined")||
            (element.startDate!.contains("Invalid") ||
                element.startDate!.contains("date") ||
                element.startDate!.contains("undefined")) ||
            isPastEvent;
      });
      bookMarkEvent.forEach((element) {
        print("bookMarkEvent ${element.startDate}");
      });
      bookMarkEvent.sort((a, b) {

        return (Utils.getFormattedDate(
                format: "MM-dd-yyyy", date: a.startDate ?? ""))
            .compareTo(Utils.getFormattedDate(
                format: "MM-dd-yyyy", date: b.startDate ?? ""));
      });
      isBookMarkLoading.value = false;
      Constants.isBookmarkLoading.value = false;
    } catch (error) {
      isBookMarkLoading.value = false;
      print("Get Book mark loading $error");
    }
  }
}

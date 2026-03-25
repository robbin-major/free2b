import 'package:flutter_template/modules/dashboard/bookmark/service/book_mark_service.dart';
import 'package:flutter_template/modules/dashboard/home/home_service.dart';
import 'package:flutter_template/modules/dashboard/home/model/event_model.dart';
import 'package:flutter_template/utils/common_service/app_pref_service.dart';
import 'package:flutter_template/utils/constants.dart';
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
      final String userID = AppPrefService.getUserUid();
      await HomeScreenService.getUserData();
      print("userID 00 ${userID}");
      if (userID.isNotEmpty) {
        print("userID 02 ${userID}");
        bookMarkEvent.value = await BookMarkService.getBookmarkEvent();
        print("bookMarkEvent.value ${bookMarkEvent.value.length}");
      }
      bookMarkEvent
          .removeWhere((element) {
        return ((element.startDate?.isEmpty ?? true) ||
            element.startDate == " " ||
            element.startDate == "Invalid date  undefined")||
            (element.startDate!.contains("Invalid") ||
                element.startDate!.contains("date") ||
                element.startDate!.contains("undefined"));
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

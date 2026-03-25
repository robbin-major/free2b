import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_template/modules/dashboard/home/home_service.dart';
import 'package:flutter_template/modules/dashboard/home/model/event_model.dart';
import 'package:flutter_template/utils/utils.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HomeController extends GetxController {
  RxList<EventModel> eventData = <EventModel>[].obs;
  RxList<EventModel> filterEventData = <EventModel>[].obs;
  RxList<EventModel> searchEventData = <EventModel>[].obs;
  RxBool isEventLoading = false.obs;
  RxBool isSearch = false.obs;
  Timer? _debounce;
  TextEditingController textEditingController = TextEditingController();
  RxList<String> categoryList = <String>[].obs;

  @override
  Future<void> onInit() async {
    await getEvent();
    super.onInit();
  }

  Future<void> getEvent() async {
    try {
      eventData.clear();
      isEventLoading.value = true;

      final events = await HomeScreenService.getEventData();
      // Filter out past events
      eventData.value = events.where((element) {
        final filterDate = Utils.getDateTime(
          date: element.startDate.toString(),
          format: "dd-MM-yyyy",
        );
        final parsedDate = DateFormat("dd-MM-yyyy").parse(filterDate);
        return !parsedDate.isBefore(DateTime.now().add(Duration(days: -1)));
      }).toList();

      // Populate filterEventData
      filterEventData.value = eventData;

      // Extract unique categories
      final categories = <String>{}; // Use Set to avoid duplicates
      for (var event in eventData) {
        final name = event.category?.first.categoryName;
        if (name != null && name.trim().isNotEmpty) {
          categories.add(name.trim());
        }
      }

      categoryList.value = categories.toList()..sort(); // Sorted optional
      print("Extracted Category List: ${categoryList.toList()}");
      isEventLoading.value = false;
      update();
    } catch (e) {
      isEventLoading.value = false;
      update();
      print("Exception :: error : $e");
    } finally {
      isEventLoading.value = false;
    }
  }

  void searchEvent({
    required String value,
  }) {
    if (value.isNotEmpty) {
      isSearch.value = true;
      if (_debounce?.isActive ?? false) _debounce?.cancel();
      _debounce = Timer(const Duration(milliseconds: 500), () {
        searchEventData.clear();
        searchEventData.value = eventData
            .where((p0) => (p0.zipCode?.contains(value) ?? false))
            .toList();
        if (searchEventData.value.isNotEmpty) {
          return;
        } else {
          print("Search ${eventData.length}");
          searchEventData.value = eventData.where((p0) {
            print("p0.category ${p0.category?[0].categoryName}");
            return (p0.category?[0].categoryName
                    ?.toLowerCase()
                    .contains(value.toLowerCase()) ??
                false);
          }).toList();
        }
      });
    } else {
      isSearch.value = false;
    }
  }
}

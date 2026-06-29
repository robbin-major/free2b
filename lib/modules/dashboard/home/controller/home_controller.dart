import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_template/modules/dashboard/home/home_service.dart';
import 'package:flutter_template/modules/dashboard/home/model/event_model.dart';
import 'package:flutter_template/utils/location_service.dart';
import 'package:flutter_template/utils/utils.dart';
import 'package:geocoding/geocoding.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class HomeController extends GetxController {
  RxList<EventModel> eventData = <EventModel>[].obs;
  RxList<EventModel> filterEventData = <EventModel>[].obs;
  RxList<EventModel> searchEventData = <EventModel>[].obs;
  RxBool isEventLoading = false.obs;
  RxBool isLocationLoading = false.obs;
  RxBool isSearch = false.obs;
  RxString locationLabel = ''.obs;
  RxString locationStatus = ''.obs;
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

  Future<void> useCurrentLocation() async {
    try {
      isLocationLoading.value = true;
      final AppLocationLookupResult result =
          await AppLocationService.getCurrentLocationIfAllowed();
      locationStatus.value = result.status;

      if (!result.hasCoordinates) {
        locationLabel.value = '';
        filterEventData.value = eventData;
        print(
          'Use current location fallback: ${result.status} ${result.message ?? ''}',
        );
        return;
      }

      final Placemark? placemark = result.placemark;
      final String neighborhood = (placemark?.subLocality ?? '').trim();
      final String city =
          (placemark?.locality ?? placemark?.subAdministrativeArea ?? '')
              .trim();
      final String state = (placemark?.administrativeArea ?? '').trim();
      locationLabel.value = neighborhood.isNotEmpty
          ? neighborhood
          : city.isNotEmpty
              ? city
              : state.isNotEmpty
                  ? state
                  : 'you';

      final List<EventModel> nearbyEvents = eventData.where((event) {
        final String eventCity = (event.city ?? '').toLowerCase();
        final String eventState = (event.state ?? '').toLowerCase();

        return (city.isNotEmpty && eventCity.contains(city.toLowerCase())) ||
            (state.isNotEmpty && eventState.contains(state.toLowerCase()));
      }).toList();

      filterEventData.value =
          nearbyEvents.isNotEmpty ? nearbyEvents : eventData;
      print(
        'Use current location applied: label=${locationLabel.value}, '
        'matchedEvents=${nearbyEvents.length}',
      );
    } catch (error) {
      print('Use current location failed: $error');
      filterEventData.value = eventData;
    } finally {
      isLocationLoading.value = false;
    }
  }

  void clearLocationFilter() {
    locationLabel.value = '';
    locationStatus.value = '';
    filterEventData.value = eventData;
  }
}

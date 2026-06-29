import 'package:flutter_template/modules/dashboard/home/home_service.dart';
import 'package:flutter_template/modules/dashboard/home/model/event_model.dart';
import 'package:flutter_template/utils/event_date_utils.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalenderController extends GetxController {
  final CalendarController calendarController = CalendarController();
  VoidCallback? collapseAgendaSheet;
  DateTime? currentDate;
  RxList<EventModel> eventData = <EventModel>[].obs;
  RxBool isLoading = false.obs;

  @override
  onInit() async {
    await doGetEventData();
    super.onInit();
  }

  Future<void> doGetEventData() async {
    try {
      isLoading.value = true;
      eventData.value = await HomeScreenService.getEventData();
      print("length ::::::::::${eventData.length}");

      eventData.removeWhere((element) {
        final DateTime? eventDate =
            EventDateUtils.parseEventDateTime(element.startDate);

        return eventDate == null ||
            !EventDateUtils.isWithinCalendarVisibilityWindow(eventDate);
      });
      print("length ::::::::::${eventData.length}");
      isLoading.value = false;
    } catch (error) {
      isLoading.value = false;
      print("DO GET CALENDER EVENT DATA ERROR $error");
    }
  }

  List<EventModel> getDataSource() {
    return eventData;
  }

  void collapseAgenda() {
    collapseAgendaSheet?.call();
  }
}

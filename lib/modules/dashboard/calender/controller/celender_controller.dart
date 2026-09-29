import 'dart:collection';

import 'package:flutter_template/modules/dashboard/home/home_service.dart';
import 'package:flutter_template/modules/dashboard/home/model/event_model.dart';
import 'package:flutter_template/utils/event_date_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalenderController extends GetxController {
  final CalendarController calendarController = CalendarController();
  VoidCallback? closeEventSheet;
  DateTime? currentDate;
  RxList<EventModel> eventData = <EventModel>[].obs;
  RxBool isLoading = false.obs;
  bool _hasLoaded = false;
  final Map<DateTime, List<EventModel>> _eventsByDay =
      <DateTime, List<EventModel>>{};
  final Map<EventModel, DateTime> _startDateByEvent =
      HashMap<EventModel, DateTime>.identity();
  final Map<EventModel, DateTime> _effectiveEndDateByEvent =
      HashMap<EventModel, DateTime>.identity();

  bool get hasLoaded => _hasLoaded;

  Future<void> ensureEventDataLoaded() async {
    if (_hasLoaded || isLoading.value) return;
    await _loadEventData();
  }

  Future<void> doGetEventData() async {
    await _loadEventData();
  }

  Future<void> _loadEventData() async {
    try {
      isLoading.value = true;
      final List<EventModel> events =
          await HomeScreenService.getCalendarEventData();
      eventData.value = events;
      _rebuildDayIndex(events);
      _hasLoaded = true;
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

  List<EventModel> eventsForDay(DateTime date) {
    return _eventsByDay[_dayKey(date)] ?? const <EventModel>[];
  }

  DateTime? eventStartDate(EventModel event) => _startDateByEvent[event];

  DateTime? eventEffectiveEndDate(EventModel event) =>
      _effectiveEndDateByEvent[event];

  void _rebuildDayIndex(List<EventModel> events) {
    final bool measurePerformance = kDebugMode || kProfileMode;
    final Stopwatch? stopwatch =
        measurePerformance ? (Stopwatch()..start()) : null;
    _eventsByDay.clear();
    _startDateByEvent.clear();
    _effectiveEndDateByEvent.clear();

    for (final EventModel event in events) {
      final DateTime? startDate =
          EventDateUtils.parseEventDateTime(event.startDate);
      if (startDate == null) continue;

      final DateTime effectiveEndDate =
          EventDateUtils.parseEventDateTime(event.endDate) ?? startDate;
      _startDateByEvent[event] = startDate;
      _effectiveEndDateByEvent[event] = effectiveEndDate;
      _eventsByDay.putIfAbsent(
        _dayKey(startDate),
        () => <EventModel>[],
      ).add(event);
    }

    for (final List<EventModel> dayEvents in _eventsByDay.values) {
      dayEvents.sort(
        (EventModel a, EventModel b) =>
            _startDateByEvent[a]!.compareTo(_startDateByEvent[b]!),
      );
    }

    stopwatch?.stop();
    if (measurePerformance) {
      debugPrint(
        '[performance] Calendar index: '
        'events=${events.length}, days=${_eventsByDay.length}, '
        'duration=${stopwatch!.elapsedMilliseconds}ms',
      );
    }
  }

  DateTime _dayKey(DateTime date) =>
      DateTime(date.year, date.month, date.day);

  void closeOpenEventSheet() {
    closeEventSheet?.call();
  }
}

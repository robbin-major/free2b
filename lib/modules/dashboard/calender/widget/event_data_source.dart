import 'package:flutter/material.dart';
import 'package:flutter_template/modules/dashboard/home/model/event_model.dart';
import 'package:flutter_template/utils/app_colors.dart';
import 'package:flutter_template/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class EventDataSource extends CalendarDataSource {
  EventDataSource(List<EventModel> source) {
    appointments = source;
  }

  @override
  DateTime getStartTime(int index) {
    DateTime parseDate = DateFormat("dd-MM-yyyy").parse(Utils.getFormattedDate(
        date: _getMeetingData(index).startDate ?? "0", format: "dd-MM-yyyy"));
    return parseDate;
  }

  @override
  DateTime getEndTime(int index) {
    // return Utils.millisecondsToDate(
    //     date: _getMeetingData(index).startDate ?? "0");

    DateTime parseDate = DateFormat("hh:mm a").parse(Utils.getDateTime(
        date: _getMeetingData(index).startDate ?? "0", format: "hh:mm a"));
    return parseDate;
  }

  // @override
  // String getSubject(int index) {
  //   return _getMeetingData(index).title ?? "";
  // }

  @override
  Color getColor(int index) {
    return _getMeetingData(index).categoryType == "Citywide Event"
        ? Color(0xFFF6E27F)
        : _getMeetingData(index).categoryType == "Community Event"
            ? Color(0xFFD4AF37)
            : Colors.red;
  }

  @override
  bool isAllDay(int index) {
    return false;
  }

  EventModel _getMeetingData(int index) {
    final dynamic event = appointments![index];
    late final EventModel eventData;
    if (event is EventModel) {
      eventData = event;
    }

    return eventData;
  }
}

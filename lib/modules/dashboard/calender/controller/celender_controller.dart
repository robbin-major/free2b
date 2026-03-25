import 'package:carousel_slider/carousel_slider.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_template/modules/dashboard/calender/widget/event_data_source.dart';
import 'package:flutter_template/modules/dashboard/home/home_service.dart';
import 'package:flutter_template/modules/dashboard/home/model/event_model.dart';
import 'package:flutter_template/utils/app_colors.dart';
import 'package:flutter_template/utils/app_string.dart';
import 'package:flutter_template/utils/assets.dart';
import 'package:flutter_template/widget/common_text.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';
import 'package:intl/intl.dart';

import '../../../../utils/utils.dart';

class CalenderController extends GetxController {
  final CalendarController calendarController = CalendarController();
  CarouselController carouselController = CarouselController();
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
        print(
            "filter event date :::::: ${element.startDate.toString().substring(0, 10)}");
        String filterDate = Utils.getFormattedDate(
            date: element.startDate.toString(), format: "dd-MM-yyyy");
        print("filterDate :::::: $filterDate");
        DateTime parseDate = DateFormat("dd-MM-yyyy").parse(
            Utils.getFormattedDate(
                date: element.startDate.toString(), format: "dd-MM-yyyy"));
        print("parseDate :::::: ${parseDate.toString().split(" ")[0]}");
        print(parseDate.isBefore(DateTime.now().add(Duration(days: -1))));
        return parseDate.isBefore(DateTime.now().add(Duration(days: -1)));
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
}

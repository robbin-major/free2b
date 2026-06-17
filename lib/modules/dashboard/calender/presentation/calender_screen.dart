import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_template/modules/dashboard/calender/controller/celender_controller.dart';
import 'package:flutter_template/modules/dashboard/calender/presentation/event_slider.dart';
import 'package:flutter_template/modules/dashboard/calender/widget/event_data_source.dart';
import 'package:flutter_template/utils/app_colors.dart';
import 'package:flutter_template/utils/app_string.dart';
import 'package:flutter_template/widget/appbar.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_calendar/calendar.dart';

class CalenderScreen extends StatefulWidget {
  CalenderScreen({super.key});

  @override
  State<CalenderScreen> createState() => _CalenderScreenState();
}

class _CalenderScreenState extends State<CalenderScreen> {
  final CalenderController _calenderController = Get.put(CalenderController());

  final Gradient free2BGradient = LinearGradient(
    colors: [Color(0xFFF6E27F), Color(0xFFD4AF37)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: CustomAppBar(
        color: AppColors.backgroundColor,
        title: AppString.calendar,
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: Obx(
        () => _calenderController.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : LayoutBuilder(
                builder: (context, constraints) {
                  final double availableHeight =
                      max(0.0, constraints.maxHeight - 24);
                  final double targetHeight = constraints.maxWidth * 1.15;
                  final double calendarHeight =
                      min(availableHeight, max(430.0, targetHeight));

                  return Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        height: calendarHeight,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppColors.backgroundLightColor,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(
                            color: AppColors.dividerColor.withOpacity(0.8),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.08),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: SfCalendar(
                          controller: _calenderController.calendarController,
                          view: CalendarView.month,
                          initialSelectedDate:
                              _calenderController.currentDate,
                          dataSource: EventDataSource(
                            _calenderController.getDataSource(),
                          ),
                          todayHighlightColor: const Color(0xFFF6E27F),
                          headerDateFormat: "MMMM yyyy",
                          headerHeight: 58,
                          viewHeaderHeight: 36,
                          initialDisplayDate: DateTime.now(),
                          monthCellBuilder: (
                            BuildContext context,
                            MonthCellDetails details,
                          ) {
                            final bool isToday = DateUtils.isSameDay(
                              details.date,
                              DateTime.now(),
                            );
                            final DateTime visibleMonthDate =
                                details.visibleDates[
                                    details.visibleDates.length ~/ 2];
                            final bool isVisibleMonth =
                                details.date.month == visibleMonthDate.month &&
                                    details.date.year == visibleMonthDate.year;

                            return Container(
                              alignment: Alignment.topCenter,
                              padding: const EdgeInsets.only(top: 10),
                              decoration: BoxDecoration(
                                border: Border(
                                  top: BorderSide(
                                    color:
                                        AppColors.dividerColor.withOpacity(0.45),
                                  ),
                                  left: BorderSide(
                                    color:
                                        AppColors.dividerColor.withOpacity(0.45),
                                  ),
                                ),
                              ),
                              child: !isVisibleMonth
                                  ? const SizedBox.shrink()
                                  : isToday
                                      ? Container(
                                          width: 34,
                                          height: 34,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: LinearGradient(
                                              colors: [
                                                Color(0xFFF6E27F),
                                                Color(0xFFD4AF37),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            ),
                                          ),
                                          alignment: Alignment.center,
                                          child: Text(
                                            '${details.date.day}',
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        )
                                      : Text(
                                          '${details.date.day}',
                                          style: TextStyle(
                                            color: AppColors.textColor,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                            );
                          },
                          selectionDecoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.transparent,
                            border: Border.all(
                              width: 1.5,
                              color: const Color(0xFFD4AF37),
                            ),
                          ),
                          headerStyle: CalendarHeaderStyle(
                            textAlign: TextAlign.center,
                            backgroundColor: AppColors.backgroundLightColor,
                            textStyle: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              foreground: Paint()
                                ..shader = const LinearGradient(
                                  colors: [
                                    Color(0xFFF6E27F),
                                    Color(0xFFD4AF37),
                                  ],
                                ).createShader(
                                  const Rect.fromLTWH(0, 0, 220, 70),
                                ),
                            ),
                          ),
                          viewHeaderStyle: ViewHeaderStyle(
                            backgroundColor: AppColors.backgroundLightColor,
                            dayTextStyle: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textColor,
                            ),
                          ),
                          monthViewSettings: const MonthViewSettings(
                            appointmentDisplayMode:
                                MonthAppointmentDisplayMode.indicator,
                            showAgenda: false,
                            showTrailingAndLeadingDates: false,
                            numberOfWeeksInView: 6,
                          ),
                          appointmentBuilder: (context, details) {
                            return Center(
                              child: Container(
                                width: 7,
                                height: 7,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFFF6E27F),
                                      Color(0xFFD4AF37),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                              ),
                            );
                          },
                          onTap: (calendarTapDetails) {
                            _calenderController.currentDate =
                                calendarTapDetails.date;
                            _showEventSlider(context, calendarTapDetails.date);
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  Future<void> _showEventSlider(BuildContext context, selectedDay) async {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: screenHeight - statusBarHeight,
          margin: EdgeInsets.only(top: statusBarHeight),
          decoration: BoxDecoration(
            color: AppColors.backgroundColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: 70,
                  height: 5,
                  margin: const EdgeInsets.only(top: 15, bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white38,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              // Actual content
              Expanded(
                child: EventSlider(
                  initialSelectedDay: selectedDay,
                  onchangeDate: (DateTime dateTime) {
                    _calenderController.calendarController.selectedDate =
                        dateTime;
                    _calenderController.calendarController.displayDate =
                        dateTime;
                  },
                  eventData: _calenderController.eventData,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

}
//
//   Future<void> _showEventSlider(BuildContext context, selectedDay) {
//     return showDialog(
//       context: context,
//       builder: (context) {
//         return EventSlider(
//           initialSelectedDay: selectedDay,
//           onchangeDate: (DateTime dateTime) {
//             _calenderController.calendarController.selectedDate = dateTime;
//             _calenderController.calendarController.displayDate = dateTime;
//           },
//           eventData: _calenderController.eventData,
//         );
//       },
//     );
//   }
// }

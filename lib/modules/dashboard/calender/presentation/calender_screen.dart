import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_template/modules/dashboard/calender/controller/celender_controller.dart';
import 'package:flutter_template/modules/dashboard/calender/presentation/event_slider.dart';
import 'package:flutter_template/modules/dashboard/home/model/event_model.dart';
import 'package:flutter_template/utils/app_colors.dart';
import 'package:flutter_template/utils/app_string.dart';
import 'package:flutter_template/utils/utils.dart';
import 'package:flutter_template/widget/appbar.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class CalenderScreen extends StatefulWidget {
  CalenderScreen({super.key});

  @override
  State<CalenderScreen> createState() => _CalenderScreenState();
}

class _CalenderScreenState extends State<CalenderScreen> {
  final CalenderController _calenderController = Get.put(CalenderController());
  static const double _calendarPadding = 16.0;
  static const double _calendarHeaderHeight = 82.0;
  static const double _weekdayHeaderHeight = 48.0;
  static const double _monthCellMinHeight = 78.0;
  static const double _monthCellTargetHeight = 96.0;
  static const double _monthGridVerticalPadding = 20.0;
  static const double _monthCardVerticalInset = 28.0;
  static const int _initialMonthPage = 500;
  late PageController _monthPageController;
  late DateTime _baseMonth;
  late DateTime _displayedMonth;

  final Gradient free2BGradient = LinearGradient(
    colors: [Color(0xFFF6E27F), Color(0xFFD4AF37)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  @override
  void initState() {
    super.initState();
    final DateTime now = DateTime.now();
    _baseMonth = DateTime(now.year, now.month);
    _displayedMonth = _baseMonth;
    _monthPageController = PageController(initialPage: _initialMonthPage);
  }

  @override
  void dispose() {
    _monthPageController.dispose();
    super.dispose();
  }

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
                  final int weeksInDisplayedMonth =
                      _weeksInMonthView(_displayedMonth);
                  final double targetCellHeight = min(
                    _monthCellTargetHeight,
                    max(
                      _monthCellMinHeight,
                      constraints.maxWidth * 0.22,
                    ),
                  );
                  final double contentHeight = _calendarHeaderHeight +
                      _weekdayHeaderHeight +
                      (targetCellHeight * weeksInDisplayedMonth) +
                      _monthGridVerticalPadding +
                      _monthCardVerticalInset;

                  return Padding(
                    padding: const EdgeInsets.all(_calendarPadding),
                    child: SingleChildScrollView(
                      child: Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          height: contentHeight,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF1A1A1A),
                                Color(0xFF111111),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(28),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.08),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.32),
                                blurRadius: 28,
                                offset: const Offset(0, 18),
                              ),
                              BoxShadow(
                                color: const Color(0xFFD4AF37)
                                    .withOpacity(0.04),
                                blurRadius: 42,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            children: [
                              SizedBox(
                                height: _calendarHeaderHeight,
                                child: Center(
                                  child: Text(
                                    DateFormat('MMMM yyyy')
                                        .format(_displayedMonth),
                                    style: TextStyle(
                                      fontSize: 27,
                                      fontWeight: FontWeight.w800,
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
                                ),
                              ),
                              _buildWeekdayHeader(),
                              SizedBox(
                                height:
                                    (targetCellHeight *
                                            weeksInDisplayedMonth) +
                                        _monthGridVerticalPadding,
                                child: PageView.builder(
                                  controller: _monthPageController,
                                  onPageChanged: _handleMonthPageChanged,
                                  itemBuilder: (context, index) {
                                    final DateTime month =
                                        _monthForPage(index);

                                    return _buildMonthGrid(
                                      month: month,
                                      cellHeight: targetCellHeight,
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(height: _monthCardVerticalInset),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  int _weeksInMonthView(DateTime month) {
    final DateTime firstDayOfMonth = DateTime(month.year, month.month);
    final DateTime lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    final int leadingWeekdaySlots = firstDayOfMonth.weekday % 7;
    return ((leadingWeekdaySlots + lastDayOfMonth.day) / 7).ceil();
  }

  DateTime _monthForPage(int page) {
    final int monthOffset = page - _initialMonthPage;
    return DateTime(_baseMonth.year, _baseMonth.month + monthOffset);
  }

  void _handleMonthPageChanged(int page) {
    final DateTime newDisplayedMonth = _monthForPage(page);

    setState(() {
      _displayedMonth =
          DateTime(newDisplayedMonth.year, newDisplayedMonth.month);
    });
  }

  Widget _buildWeekdayHeader() {
    const List<String> weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return SizedBox(
      height: _weekdayHeaderHeight,
      child: Row(
        children: List.generate(
          weekdays.length,
          (index) {
            final String day = weekdays[index];

            return Expanded(
              child: Center(
                child: Text(
                  day,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: index == 0
                        ? const Color(0xFFF6D05F)
                        : Colors.white.withOpacity(0.64),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMonthGrid({
    required DateTime month,
    required double cellHeight,
  }) {
    final DateTime firstDayOfMonth = DateTime(month.year, month.month);
    final DateTime lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    final int leadingSlots = firstDayOfMonth.weekday % 7;
    final int dayCount = lastDayOfMonth.day;
    final int trailingSlots = (7 - ((leadingSlots + dayCount) % 7)) % 7;
    final int totalCells = leadingSlots + dayCount + trailingSlots;

    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.05)),
        ),
      ),
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: totalCells,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 7,
          mainAxisExtent: cellHeight,
        ),
        itemBuilder: (context, index) {
          if (index < leadingSlots || index >= leadingSlots + dayCount) {
            return const SizedBox.shrink();
          }

          final DateTime date =
              DateTime(month.year, month.month, index - leadingSlots + 1);

          return _buildDateCell(date);
        },
      ),
    );
  }

  Widget _buildDateCell(DateTime date) {
    final bool isToday = DateUtils.isSameDay(date, DateTime.now());
    final List<EventModel> eventsForDay = _eventsForDay(date);
    final bool hasEvents = eventsForDay.isNotEmpty;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        _calenderController.currentDate = date;
        _calenderController.calendarController.selectedDate = date;
        _calenderController.calendarController.displayDate = date;
        _showEventSlider(context, date);
      },
      child: Container(
        alignment: Alignment.center,
        child: Text(
          '${date.day}',
          style: TextStyle(
            color: hasEvents
                ? const Color(0xFFF6D05F)
                : Colors.white.withOpacity(isToday ? 0.95 : 0.82),
            fontSize: hasEvents ? 25 : 23,
            fontWeight: hasEvents ? FontWeight.w800 : FontWeight.w500,
            height: 1,
            shadows: hasEvents
                ? [
                    Shadow(
                      color: const Color(0xFFD4AF37).withOpacity(0.75),
                      blurRadius: 18,
                    ),
                    Shadow(
                      color: const Color(0xFFD4AF37).withOpacity(0.42),
                      blurRadius: 34,
                    ),
                    Shadow(
                      color: const Color(0xFFF6E27F).withOpacity(0.22),
                      blurRadius: 52,
                    ),
                  ]
                : null,
          ),
        ),
      ),
    );
  }

  List<EventModel> _eventsForDay(DateTime date) {
    return _calenderController.eventData.where((event) {
      final DateTime? eventDate = _eventDate(event);
      return eventDate != null && DateUtils.isSameDay(eventDate, date);
    }).toList();
  }

  DateTime? _eventDate(EventModel event) {
    final String? startDate = event.startDate;

    if (startDate == null || startDate.isEmpty) {
      return null;
    }

    try {
      return DateFormat('dd-MM-yyyy').parse(
        Utils.getFormattedDate(date: startDate, format: 'dd-MM-yyyy'),
      );
    } catch (_) {
      return null;
    }
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

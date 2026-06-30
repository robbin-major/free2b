import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_template/modules/dashboard/calender/controller/celender_controller.dart';
import 'package:flutter_template/modules/dashboard/home/model/event_model.dart';
import 'package:flutter_template/utils/app_colors.dart';
import 'package:flutter_template/utils/app_string.dart';
import 'package:flutter_template/utils/event_date_utils.dart';
import 'package:flutter_template/utils/navigation_utils/navigation.dart';
import 'package:flutter_template/utils/navigation_utils/routes.dart';
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
  static const EdgeInsets _calendarPadding =
      EdgeInsets.fromLTRB(16, 12, 16, 12);
  static const double _calendarHeaderHeight = 58.0;
  static const double _weekdayHeaderHeight = 34.0;
  static const double _monthCellMinHeight = 48.0;
  static const double _monthCellTargetHeight = 76.0;
  static const double _monthGridVerticalPadding = 10.0;
  static const double _monthLegendHeight = 34.0;
  static const double _monthCardVerticalInset = 12.0;
  static const double _calendarBottomReserve = 24.0;
  static const Color _mutedGold = Color(0xFFD6B75A);
  static const int _initialMonthPage = 500;
  late PageController _monthPageController;
  late DateTime _baseMonth;
  late DateTime _displayedMonth;
  late DateTime _selectedDate;
  bool _isEventSheetOpen = false;

  @override
  void initState() {
    super.initState();
    final DateTime now = DateTime.now();
    _baseMonth = DateTime(now.year, now.month);
    _displayedMonth = _baseMonth;
    _selectedDate = DateTime(now.year, now.month, now.day);
    _monthPageController = PageController(initialPage: _initialMonthPage);
    _calenderController.closeEventSheet = _closeEventSheet;
  }

  @override
  void dispose() {
    if (_calenderController.closeEventSheet == _closeEventSheet) {
      _calenderController.closeEventSheet = null;
    }
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
        centerTitle: true,
        automaticallyImplyLeading: false,
        fontColor: _mutedGold,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      body: Obx(
        () => _calenderController.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : LayoutBuilder(
                builder: (context, constraints) {
                  final int weeksInDisplayedMonth =
                      _weeksInMonthView(_displayedMonth);
                  final double availableBodyHeight = max(
                    0.0,
                    constraints.maxHeight -
                        _calendarPadding.vertical -
                        _calendarBottomReserve,
                  );
                  final double fixedCardHeight = _calendarHeaderHeight +
                      _weekdayHeaderHeight +
                      _monthGridVerticalPadding +
                      _monthLegendHeight +
                      _monthCardVerticalInset;
                  final double heightBasedCellHeight = max(
                    _monthCellMinHeight,
                    (availableBodyHeight - fixedCardHeight) /
                        weeksInDisplayedMonth,
                  );
                  final double targetCellHeight = min(
                    _monthCellTargetHeight,
                    min(constraints.maxWidth * 0.18, heightBasedCellHeight),
                  );
                  final double contentHeight = _calendarHeaderHeight +
                      _weekdayHeaderHeight +
                      (targetCellHeight * weeksInDisplayedMonth) +
                      _monthGridVerticalPadding +
                      _monthLegendHeight +
                      _monthCardVerticalInset;

                  return Padding(
                    padding: _calendarPadding,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        height: min(contentHeight, availableBodyHeight),
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
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: const Color(0xFF4A4A4A).withOpacity(0.42),
                            width: 1.0,
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
                                    fontSize: 23,
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
                                  (targetCellHeight * weeksInDisplayedMonth) +
                                      _monthGridVerticalPadding,
                              child: PageView.builder(
                                controller: _monthPageController,
                                onPageChanged: _handleMonthPageChanged,
                                itemBuilder: (context, index) {
                                  final DateTime month = _monthForPage(index);

                                  return _buildMonthGrid(
                                    month: month,
                                    cellHeight: targetCellHeight,
                                  );
                                },
                              ),
                            ),
                            _buildEventLegend(),
                            const SizedBox(height: _monthCardVerticalInset),
                          ],
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
      _selectedDate = _displayedMonth;
    });
  }

  Widget _buildWeekdayHeader() {
    const List<String> weekdays = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];
    final int currentWeekdayIndex = DateTime.now().weekday % 7;

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
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: index == currentWeekdayIndex
                        ? _mutedGold
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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
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
    final bool isPastDate = _isPastDate(date);
    final bool isSelected = DateUtils.isSameDay(date, _selectedDate);
    final List<EventModel> eventsForDay = _eventsForDay(date);
    final bool hasEvents = eventsForDay.isNotEmpty;
    final bool hasActiveEvents = hasEvents && !isPastDate;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        _calenderController.currentDate = date;
        _calenderController.calendarController.selectedDate = date;
        _calenderController.calendarController.displayDate = date;
        setState(() {
          _selectedDate = date;
        });
        _showEventsForDate(date);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color:
              isSelected ? Colors.white.withOpacity(0.06) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          '${date.day}',
          style: TextStyle(
            color: hasActiveEvents
                ? _mutedGold
                : Colors.white.withOpacity(isToday ? 0.95 : 0.82),
            fontSize: hasActiveEvents ? 19 : 18,
            fontWeight: hasActiveEvents ? FontWeight.w800 : FontWeight.w500,
            height: 1,
            shadows: hasActiveEvents
                ? [
                    Shadow(
                      color: _mutedGold.withOpacity(0.42),
                      blurRadius: 10,
                    ),
                    Shadow(
                      color: _mutedGold.withOpacity(0.20),
                      blurRadius: 22,
                    ),
                  ]
                : hasEvents && isPastDate
                    ? [
                        Shadow(
                          color: Colors.white.withOpacity(0.16),
                          blurRadius: 8,
                        ),
                      ]
                : null,
          ),
        ),
      ),
    );
  }

  Widget _buildEventLegend() {
    return SizedBox(
      height: _monthLegendHeight,
      child: Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Gold dates are upcoming events',
              style: TextStyle(
                color: Colors.white.withOpacity(0.58),
                fontSize: 12,
                fontWeight: FontWeight.w500,
                letterSpacing: 0,
              ),
            ),
          ],
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

  List<EventModel> _sortedEventsForDay(DateTime date) {
    return _eventsForDay(date)
      ..sort((a, b) {
        final DateTime? aDate = _eventDate(a);
        final DateTime? bDate = _eventDate(b);

        if (aDate == null || bDate == null) {
          return 0;
        }

        return aDate.compareTo(bDate);
      });
  }

  DateTime? _eventDate(EventModel event) {
    return EventDateUtils.parseEventDateTime(event.startDate);
  }

  bool _isPastDate(DateTime date) {
    final DateTime today = DateTime.now();
    return DateTime(date.year, date.month, date.day)
        .isBefore(DateTime(today.year, today.month, today.day));
  }

  void _showEventsForDate(DateTime date) {
    final List<EventModel> selectedEvents = _sortedEventsForDay(date);
    final double initialSize = selectedEvents.length > 1 ? 0.58 : 0.42;

    _isEventSheetOpen = true;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withOpacity(0.62),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: initialSize,
          minChildSize: 0.34,
          maxChildSize: 0.88,
          builder: (context, scrollController) {
            return _buildEventSheetContent(
              selectedDate: date,
              selectedEvents: selectedEvents,
              scrollController: scrollController,
            );
          },
        );
      },
    ).whenComplete(() {
      _isEventSheetOpen = false;
    });
  }

  void _closeEventSheet() {
    if (_isEventSheetOpen && mounted) {
      Navigator.of(context).maybePop();
    }
  }

  Widget _buildEventSheetContent({
    required DateTime selectedDate,
    required List<EventModel> selectedEvents,
    required ScrollController scrollController,
  }) {
    final String eventCount =
        '${selectedEvents.length} ${selectedEvents.length == 1 ? 'event' : 'events'}';

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF111112),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: ListView(
        controller: scrollController,
        padding: const EdgeInsets.fromLTRB(0, 10, 0, 28),
        children: [
          Center(
            child: Container(
              width: 58,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.38),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 22, 20, 16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('EEEE, MMMM d').format(selectedDate),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        eventCount,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.62),
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _buildSheetDayButton(
                  icon: Icons.close,
                  onTap: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.white.withOpacity(0.08)),
          if (selectedEvents.isEmpty)
            SizedBox(
              height: 220,
              child: _buildEmptySheetDay(),
            )
          else
            ...[
              const SizedBox(height: 16),
              for (int index = 0; index < selectedEvents.length; index++) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: _buildAgendaCard(selectedEvents[index]),
                ),
                if (index != selectedEvents.length - 1)
                  const SizedBox(height: 12),
              ],
            ],
        ],
      ),
    );
  }

  Widget _buildSheetDayButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: Ink(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: _mutedGold,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildEmptySheetDay() {
    return Center(
      child: Text(
        AppString.noAnEvent,
        style: TextStyle(
          color: Colors.white.withOpacity(0.58),
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildAgendaCard(EventModel event) {
    final DateTime? eventDateTime = _eventDate(event);
    final bool ended = eventDateTime != null &&
        EventDateUtils.hasEventEnded(eventDateTime);
    final String timeText = _formatEventTime(eventDateTime);
    final String location = _eventLocation(event);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.of(context).pop();
          Navigation.pushNamed(
            Routes.detailsScreen,
            arg: event,
          );
        },
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.08),
                Colors.white.withOpacity(0.035),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: Colors.white.withOpacity(0.10),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 96,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color:
                            ended ? Colors.white.withOpacity(0.42) : _mutedGold,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        timeText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: ended
                              ? Colors.white.withOpacity(0.70)
                              : _mutedGold,
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                          letterSpacing: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 54,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                color: Colors.white.withOpacity(0.08),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.title ?? '',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        height: 1.18,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (location.isNotEmpty)
                      Row(
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 15,
                            color: Colors.white.withOpacity(0.55),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              location,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.58),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (ended) ...[
                      const SizedBox(height: 7),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 12,
                              color: Colors.white.withOpacity(0.62),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              AppString.eventEnded,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.66),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.chevron_right,
                color: _mutedGold,
                size: 26,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatEventTime(DateTime? eventDateTime) {
    if (eventDateTime == null) {
      return '--';
    }

    return DateFormat('h:mm a').format(eventDateTime);
  }

  String _eventLocation(EventModel event) {
    if ((event.aptSuiteOther ?? '').trim().isNotEmpty) {
      return event.aptSuiteOther!.trim();
    }

    if ((event.address ?? '').trim().isNotEmpty) {
      return event.address!.trim();
    }

    return [
      event.city,
      event.state,
    ].where((value) => (value ?? '').trim().isNotEmpty).join(', ');
  }

}

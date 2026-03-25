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
            : Padding(
          padding: const EdgeInsets.all(12.0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SfCalendar(
              controller: _calenderController.calendarController,
              view: CalendarView.month,
              initialSelectedDate: _calenderController.currentDate,
              dataSource: EventDataSource(_calenderController.getDataSource()),
              todayHighlightColor: Color(0xFFF6E27F),
              headerDateFormat: "MMMM",
              headerHeight: 50,
              viewHeaderHeight: 30,
              initialDisplayDate: DateTime.now(),

              monthCellBuilder: (BuildContext context, MonthCellDetails details) {
                final bool isToday = DateUtils.isSameDay(details.date, DateTime.now());

                return Center(
                  child: isToday
                      ? Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFFF6E27F), Color(0xFFD4AF37)],
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
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              },

              selectionDecoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.transparent,
                border: Border.all(
                  width: 1,
                  color: Color(0xFFF6E27F), // We'll overlay gradient later
                ),
                // Use a foreground gradient as a border
              ),

              headerStyle: CalendarHeaderStyle(
                textAlign: TextAlign.center,
                textStyle: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  foreground: Paint()
                    ..shader = LinearGradient(
                      colors: [Color(0xFFF6E27F), Color(0xFFD4AF37)],
                    ).createShader(Rect.fromLTWH(0, 0, 200, 70)),
                ),
              ),

              viewHeaderStyle: ViewHeaderStyle(
                dayTextStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textColor,
                ),
              ),

              monthViewSettings: MonthViewSettings(
                appointmentDisplayMode: MonthAppointmentDisplayMode.indicator,
                showAgenda: false,
              ),

              appointmentBuilder: (context, details) {
                return Center(
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFFF6E27F), Color(0xFFD4AF37)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                );
              },

              onTap: (calendarTapDetails) {
                _calenderController.currentDate = calendarTapDetails.date;
                _showEventSlider(context, calendarTapDetails.date);
              },
            ),
          ),
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
                    _calenderController.calendarController.selectedDate = dateTime;
                    _calenderController.calendarController.displayDate = dateTime;
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


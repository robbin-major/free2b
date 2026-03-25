import 'dart:developer';

import 'package:dotted_line/dotted_line.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_template/modules/dashboard/home/model/event_model.dart';
import 'package:flutter_template/utils/app_colors.dart';
import 'package:flutter_template/utils/app_string.dart';
import 'package:flutter_template/utils/assets.dart';
import 'package:flutter_template/widget/common_text.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../utils/navigation_utils/navigation.dart';
import '../../../../utils/navigation_utils/routes.dart';
import '../../../../utils/utils.dart';
import '../../home/controller/home_controller.dart';

class EventSlider extends StatefulWidget {
  final DateTime initialSelectedDay;
  final List<EventModel> eventData;
  final Function(DateTime dateTime)? onchangeDate;

  const EventSlider({
    super.key,
    required this.initialSelectedDay,
    this.onchangeDate,
    required this.eventData,
  });

  @override
  _EventSliderState createState() => _EventSliderState();
}

class _EventSliderState extends State<EventSlider> {
  late PageController _pageController;
  late DateTime _currentDate;

  @override
  void initState() {
    super.initState();
    _currentDate = widget.initialSelectedDay;
    _pageController = PageController(initialPage: 500, viewportFraction: 0.8);
  }

  void _onPageChanged(int index) {
    final selectedDate = widget.initialSelectedDay
        .add(Duration(days: index - _pageController.initialPage));
    setState(() {
      _currentDate = selectedDate;
    });
    widget.onchangeDate?.call(selectedDate);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (details.primaryDelta! > 10) {
          Navigator.of(context).pop(); // Swipe down to close
        }
      },
      onTap: () {
        Get.back();
      },
      child: PageView.builder(
        scrollDirection: Axis.vertical,
        controller: _pageController,
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) {
          final pageDate = widget.initialSelectedDay.add(
            Duration(days: index - _pageController.initialPage),
          );

          final formattedPageDate =
          DateFormat("dd-MM-yyyy").format(pageDate);

          final pageEvents = widget.eventData.where((event) {
            final eventDate = Utils.getFormattedDate(
              format: "dd-MM-yyyy",
              date: event.startDate ?? "0",
            );
            return eventDate == formattedPageDate;
          }).toList();

          return Padding(
            padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 10.w),
            child: Container(
              padding: EdgeInsets.all(30.sp),
              decoration: BoxDecoration(
                color: AppColors.bottomSheetColor,
                borderRadius: BorderRadius.circular(30.r),
              ),
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      text: DateFormat('dd').format(pageDate),
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        fontSize: 22.sp,
                      ),
                      children: [
                        TextSpan(
                          text: "  ${DateFormat('EEEE').format(pageDate)}",
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        )
                      ],
                    ),
                  ),
                  DottedLine(
                    dashColor: AppColors.disableButtonColor,
                  ).paddingSymmetric(vertical: 20.h),
                  pageEvents.isNotEmpty
                      ? Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SvgPicture.asset(IconAsset.calenderIcon)
                          .paddingOnly(right: 12.w),
                      Expanded(
                        child: Column(
                          children: List.generate(
                            pageEvents.length,
                                (index) => GestureDetector(
                              onTap: () {
                                Navigation.pushNamed(
                                  Routes.detailsScreen,
                                  arg: pageEvents[index],
                                );
                              },
                              child: Padding(
                                padding: EdgeInsets.only(bottom: 5.h),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 4.w,
                                      height: 20.h,
                                      decoration: BoxDecoration(
                                        color: _getColorForCategory(
                                          pageEvents[index].categoryType,
                                        ),
                                        borderRadius:
                                        BorderRadius.circular(20.r),
                                      ),
                                    ).paddingOnly(right: 12.w),
                                    Flexible(
                                      child: CommonText(
                                        text: pageEvents[index].title ??
                                            "",
                                        overflow: TextOverflow.ellipsis,
                                        fontSize: 14.sp,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                      : Center(
                    child: SizedBox(
                      height: 310.h,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(IconAsset.smileys),
                          12.h.verticalSpace,
                          CommonText(
                            text: AppString.noAnEvent,
                            color: AppColors.textLightColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getColorForCategory(String? category) {
    switch (category) {
      case "Citywide Event":
        return Color(0xFFF6E27F);
      case "Community Event":
        return Color(0xFFD4AF37);
      default:
        return Colors.red;
    }
  }
}


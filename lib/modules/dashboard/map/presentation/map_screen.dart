import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/modules/dashboard/home/controller/home_controller.dart';
import 'package:flutter_template/modules/dashboard/home/model/event_model.dart';
import 'package:flutter_template/utils/app_colors.dart';
import 'package:flutter_template/utils/event_date_utils.dart';
import 'package:flutter_template/utils/navigation_utils/navigation.dart';
import 'package:flutter_template/utils/navigation_utils/routes.dart';
import 'package:flutter_template/widget/common_text.dart';
import 'package:flutter_template/widget/event_image.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final HomeController _homeController;
  final TextEditingController _zipController = TextEditingController();
  bool _isNight = true;
  bool _showTray = true;
  String _zipFilter = '';

  static const List<Alignment> _featuredSlots = [
    Alignment(-0.66, -0.58),
    Alignment(0.18, -0.66),
    Alignment(-0.58, 0.04),
    Alignment(0.30, 0.16),
    Alignment(-0.10, 0.62),
  ];

  static const List<Alignment> _pinSlots = [
    Alignment(-0.24, -0.30),
    Alignment(0.52, -0.22),
    Alignment(-0.72, 0.42),
    Alignment(0.56, 0.58),
    Alignment(-0.32, 0.78),
  ];

  @override
  void initState() {
    super.initState();
    _homeController = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(HomeController());
  }

  @override
  void dispose() {
    _zipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color background =
        _isNight ? const Color(0xFF060812) : const Color(0xFFF3F6FA);

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _ChicagoMapPainter(isNight: _isNight),
              ),
            ),
            Positioned(
              top: 10.h,
              left: 14.w,
              right: 14.w,
              child: _MapHeader(
                isNight: _isNight,
                zipController: _zipController,
                onModeChanged: (value) => setState(() => _isNight = value),
                onZipChanged: (value) => setState(() {
                  _zipFilter = value.trim();
                }),
                onClearZip: _zipFilter.isEmpty
                    ? null
                    : () {
                        _zipController.clear();
                        setState(() => _zipFilter = '');
                      },
              ),
            ),
            Positioned(
              top: 112.h,
              left: 0,
              right: 0,
              bottom: _showTray ? 162.h : 44.h,
              child: Obx(() {
                final List<EventModel> events = _visibleEvents();
                final List<EventModel> featured = events.take(5).toList();
                final List<EventModel> pins = events.skip(5).take(5).toList();

                if (_homeController.isEventLoading.value &&
                    _homeController.eventData.isEmpty) {
                  return Center(
                    child: CircularProgressIndicator(
                      color: _accentColor,
                      strokeWidth: 2.4,
                    ),
                  );
                }

                return Stack(
                  children: [
                    for (int index = 0; index < pins.length; index++)
                      Align(
                        alignment: _pinSlots[index % _pinSlots.length],
                        child: _SmallEventPin(
                          color: _accentFor(index + featured.length),
                          onTap: () => _openEvent(pins[index]),
                        ),
                      ),
                    for (int index = 0; index < featured.length; index++)
                      Align(
                        alignment: _featuredSlots[index],
                        child: _FeaturedEventCallout(
                          event: featured[index],
                          color: _accentFor(index),
                          isNight: _isNight,
                          onTap: () => _openEvent(featured[index]),
                        ),
                      ),
                    const Align(
                      alignment: Alignment(0.14, 0.80),
                      child: _YouAreHerePin(),
                    ),
                    if (featured.isEmpty)
                      _EmptyMapState(
                        isNight: _isNight,
                        zipFilter: _zipFilter,
                      ),
                  ],
                );
              }),
            ),
            Positioned(
              left: 14.w,
              right: 14.w,
              bottom: 16.h,
              child: Obx(() {
                final List<EventModel> events = _visibleEvents();
                if (!_showTray) {
                  return Align(
                    alignment: Alignment.centerRight,
                    child: _ShowTrayButton(
                      count: events.length,
                      onTap: () => setState(() => _showTray = true),
                    ),
                  );
                }

                return _EventTray(
                  events: events,
                  zipFilter: _zipFilter,
                  onClose: () => setState(() => _showTray = false),
                  onTapEvent: _openEvent,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Color get _accentColor => const Color(0xFFFF58F3);

  List<EventModel> _visibleEvents() {
    final String filter = _normalizeZip(_zipFilter);
    final List<EventModel> source = _homeController.eventData.toList();
    final List<EventModel> filtered = filter.isEmpty
        ? source
        : source.where((event) {
            final String eventZip = _normalizeZip(event.zipCode);
            return eventZip.startsWith(filter) ||
                (filter.length >= 3 &&
                    eventZip.length >= 3 &&
                    eventZip.substring(0, 3) == filter.substring(0, 3));
          }).toList();

    final List<EventModel> events = filter.isEmpty ? source : filtered;
    events.sort((a, b) {
      final DateTime? aDate = EventDateUtils.parseEventDateTime(a.startDate);
      final DateTime? bDate = EventDateUtils.parseEventDateTime(b.startDate);
      if (aDate == null && bDate == null) {
        return (a.title ?? '').compareTo(b.title ?? '');
      }
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return aDate.compareTo(bDate);
    });

    return events;
  }

  String _normalizeZip(String? value) {
    return (value ?? '').replaceAll(RegExp(r'[^0-9]'), '');
  }

  Color _accentFor(int index) {
    const List<Color> colors = [
      Color(0xFFFF58F3),
      Color(0xFF2D9BFF),
      Color(0xFF38D77D),
      Color(0xFFFFB84E),
      Color(0xFFC06BFF),
    ];
    return colors[index % colors.length];
  }

  void _openEvent(EventModel event) {
    Navigation.pushNamed(Routes.detailsScreen, arg: event);
  }
}

class _MapHeader extends StatelessWidget {
  const _MapHeader({
    required this.isNight,
    required this.zipController,
    required this.onModeChanged,
    required this.onZipChanged,
    required this.onClearZip,
  });

  final bool isNight;
  final TextEditingController zipController;
  final ValueChanged<bool> onModeChanged;
  final ValueChanged<String> onZipChanged;
  final VoidCallback? onClearZip;

  @override
  Widget build(BuildContext context) {
    final Color surface =
        isNight ? const Color(0xD90B0F18) : Colors.white.withOpacity(0.92);
    final Color textColor = isNight ? AppColors.textColor : const Color(0xFF172033);
    final Color muted =
        isNight ? AppColors.textLightColor : const Color(0xFF637083);

    return Column(
      children: [
        Row(
          children: [
            _RoundIconButton(
              icon: Icons.search_rounded,
              isNight: isNight,
            ),
            const Spacer(),
            CommonText(
              text: 'Free2B',
              color: const Color(0xFFFF58F3),
              fontSize: 25.sp,
              fontWeight: FontWeight.w800,
            ),
            const Spacer(),
            _RoundIconButton(
              icon: Icons.tune_rounded,
              isNight: isNight,
            ),
          ],
        ),
        10.h.verticalSpace,
        Container(
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: surface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isNight
                  ? Colors.white.withOpacity(0.10)
                  : const Color(0xFFE1E6EF),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isNight ? 0.24 : 0.08),
                blurRadius: 18.r,
                offset: Offset(0, 8.h),
              ),
            ],
          ),
          child: Row(
            children: [
              _ModePill(
                label: 'Night',
                icon: Icons.dark_mode_rounded,
                selected: isNight,
                onTap: () => onModeChanged(true),
              ),
              _ModePill(
                label: 'Day',
                icon: Icons.light_mode_rounded,
                selected: !isNight,
                onTap: () => onModeChanged(false),
              ),
              8.w.horizontalSpace,
              Expanded(
                child: SizedBox(
                  height: 38.h,
                  child: TextField(
                    controller: zipController,
                    keyboardType: TextInputType.number,
                    maxLength: 5,
                    onChanged: onZipChanged,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: 'ZIP',
                      hintStyle: TextStyle(
                        color: muted,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                      ),
                      prefixIcon: Icon(
                        Icons.location_on_outlined,
                        color: muted,
                        size: 17.sp,
                      ),
                      suffixIcon: onClearZip == null
                          ? null
                          : GestureDetector(
                              onTap: onClearZip,
                              child: Icon(
                                Icons.close_rounded,
                                color: muted,
                                size: 17.sp,
                              ),
                            ),
                      filled: true,
                      fillColor: isNight
                          ? Colors.black.withOpacity(0.22)
                          : const Color(0xFFF3F6FA),
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ModePill extends StatelessWidget {
  const _ModePill({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 38.h,
        padding: EdgeInsets.symmetric(horizontal: 11.w),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF5B23E5) : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: const Color(0xFF733CFF).withOpacity(0.30),
                    blurRadius: 14.r,
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : AppColors.textLightColor,
              size: 16.sp,
            ),
            5.w.horizontalSpace,
            CommonText(
              text: label,
              color: selected ? Colors.white : AppColors.textLightColor,
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.isNight});

  final IconData icon;
  final bool isNight;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40.w,
      width: 40.w,
      decoration: BoxDecoration(
        color: isNight ? Colors.black.withOpacity(0.34) : Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: isNight ? Colors.white.withOpacity(0.08) : const Color(0xFFE1E6EF),
        ),
      ),
      child: Icon(
        icon,
        color: isNight ? AppColors.textColor : const Color(0xFF172033),
        size: 23.sp,
      ),
    );
  }
}

class _FeaturedEventCallout extends StatelessWidget {
  const _FeaturedEventCallout({
    required this.event,
    required this.color,
    required this.isNight,
    required this.onTap,
  });

  final EventModel event;
  final Color color;
  final bool isNight;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 136.w,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: isNight
                    ? const Color(0xE80A0D14)
                    : Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: color.withOpacity(0.88), width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(isNight ? 0.34 : 0.18),
                    blurRadius: 18.r,
                    spreadRadius: 0.5.r,
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  EventImage(
                    imageUrl: event.image,
                    height: 34.w,
                    width: 34.w,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  7.w.horizontalSpace,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CommonText(
                          text: _eventTitle(event),
                          color: isNight
                              ? AppColors.textColor
                              : const Color(0xFF172033),
                          fontSize: 10.5.sp,
                          fontWeight: FontWeight.w800,
                          maxLine: 2,
                          softWrap: true,
                        ),
                        4.h.verticalSpace,
                        CommonText(
                          text: _eventTime(event),
                          color: isNight
                              ? AppColors.textLightColor
                              : const Color(0xFF637083),
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w700,
                          maxLine: 1,
                          softWrap: false,
                        ),
                        if ((event.zipCode ?? '').trim().isNotEmpty) ...[
                          3.h.verticalSpace,
                          CommonText(
                            text: event.zipCode!.trim(),
                            color: color,
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w800,
                            maxLine: 1,
                            softWrap: false,
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            _GlowStem(color: color),
          ],
        ),
      ),
    );
  }
}

class _SmallEventPin extends StatelessWidget {
  const _SmallEventPin({
    required this.color,
    required this.onTap,
  });

  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 30.w,
            width: 30.w,
            decoration: BoxDecoration(
              color: const Color(0xE80A0D14),
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 1.4),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.42),
                  blurRadius: 14.r,
                ),
              ],
            ),
            child: Icon(
              Icons.place_rounded,
              color: color,
              size: 17.sp,
            ),
          ),
          Container(
            height: 18.h,
            width: 2.w,
            color: color.withOpacity(0.72),
          ),
        ],
      ),
    );
  }
}

class _YouAreHerePin extends StatelessWidget {
  const _YouAreHerePin();

  @override
  Widget build(BuildContext context) {
    const Color color = Color(0xFF1587FF);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: Colors.white.withOpacity(0.50)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.50),
                blurRadius: 16.r,
              ),
            ],
          ),
          child: CommonText(
            text: 'You are here',
            color: AppColors.textColor,
            fontSize: 11.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        _GlowStem(color: color),
      ],
    );
  }
}

class _GlowStem extends StatelessWidget {
  const _GlowStem({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 22.h,
          width: 2.w,
          decoration: BoxDecoration(
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.55),
                blurRadius: 10.r,
              ),
            ],
          ),
        ),
        Container(
          height: 8.w,
          width: 18.w,
          decoration: BoxDecoration(
            border: Border.all(color: color.withOpacity(0.90), width: 1.5),
            borderRadius: BorderRadius.circular(50.r),
          ),
        ),
      ],
    );
  }
}

class _EventTray extends StatelessWidget {
  const _EventTray({
    required this.events,
    required this.zipFilter,
    required this.onClose,
    required this.onTapEvent,
  });

  final List<EventModel> events;
  final String zipFilter;
  final VoidCallback onClose;
  final ValueChanged<EventModel> onTapEvent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(13.w, 10.h, 13.w, 13.h),
      decoration: BoxDecoration(
        color: const Color(0xF20C0D13),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.42),
            blurRadius: 24.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              height: 4.h,
              width: 42.w,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(99.r),
              ),
            ),
          ),
          8.h.verticalSpace,
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(
                      text: zipFilter.isEmpty
                          ? 'Events around Chicago'
                          : 'Events near $zipFilter',
                      color: AppColors.textColor,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                    ),
                    2.h.verticalSpace,
                    CommonText(
                      text: events.isEmpty
                          ? 'No events to show yet'
                          : '${events.length} real event${events.length == 1 ? '' : 's'} available',
                      color: AppColors.textLightColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onClose,
                child: Container(
                  height: 32.w,
                  width: 32.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    color: AppColors.textLightColor,
                    size: 20.sp,
                  ),
                ),
              ),
            ],
          ),
          11.h.verticalSpace,
          SizedBox(
            height: 78.h,
            child: events.isEmpty
                ? Center(
                    child: CommonText(
                      text: 'Try another ZIP code.',
                      color: AppColors.textLightColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: math.min(events.length, 12),
                    separatorBuilder: (_, __) => 10.w.horizontalSpace,
                    itemBuilder: (context, index) {
                      final EventModel event = events[index];
                      return GestureDetector(
                        onTap: () => onTapEvent(event),
                        child: SizedBox(
                          width: 118.w,
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: EventImage(
                                  imageUrl: event.image,
                                  height: 78.h,
                                  width: 118.w,
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                              ),
                              Positioned.fill(
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.r),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.74),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 8.w,
                                right: 8.w,
                                bottom: 7.h,
                                child: CommonText(
                                  text: _eventTitle(event),
                                  color: AppColors.textColor,
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w800,
                                  maxLine: 2,
                                  softWrap: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ShowTrayButton extends StatelessWidget {
  const _ShowTrayButton({required this.count, required this.onTap});

  final int count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: const Color(0xF20C0D13),
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(color: Colors.white.withOpacity(0.14)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.keyboard_arrow_up_rounded,
              color: AppColors.textColor,
              size: 20.sp,
            ),
            5.w.horizontalSpace,
            CommonText(
              text: '$count event${count == 1 ? '' : 's'}',
              color: AppColors.textColor,
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyMapState extends StatelessWidget {
  const _EmptyMapState({required this.isNight, required this.zipFilter});

  final bool isNight;
  final String zipFilter;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 230.w,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isNight ? const Color(0xE80A0D14) : Colors.white.withOpacity(0.94),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isNight ? Colors.white.withOpacity(0.12) : const Color(0xFFE1E6EF),
          ),
        ),
        child: CommonText(
          text: zipFilter.isEmpty
              ? 'No events are available on the map yet.'
              : 'No events matched that ZIP code yet.',
          color: isNight ? AppColors.textColor : const Color(0xFF172033),
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _ChicagoMapPainter extends CustomPainter {
  const _ChicagoMapPainter({required this.isNight});

  final bool isNight;

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Paint background = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isNight
            ? const [
                Color(0xFF050712),
                Color(0xFF0A101A),
                Color(0xFF06080D),
              ]
            : const [
                Color(0xFFF5F8FC),
                Color(0xFFEAF0F7),
                Color(0xFFF9FBFE),
              ],
      ).createShader(rect);
    canvas.drawRect(rect, background);

    _drawLake(canvas, size);
    _drawChicagoGrid(canvas, size);
    _drawMainRoutes(canvas, size);
    _drawLabels(canvas, size);
  }

  void _drawLake(Canvas canvas, Size size) {
    final Path lake = Path()
      ..moveTo(size.width * 0.73, 0)
      ..cubicTo(
        size.width * 0.65,
        size.height * 0.22,
        size.width * 0.78,
        size.height * 0.42,
        size.width * 0.70,
        size.height * 0.63,
      )
      ..cubicTo(
        size.width * 0.64,
        size.height * 0.78,
        size.width * 0.78,
        size.height * 0.92,
        size.width * 0.74,
        size.height,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(
      lake,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: isNight
              ? const [
                  Color(0x00136887),
                  Color(0xAA08385B),
                  Color(0xFF061A31),
                ]
              : const [
                  Color(0x332E9BEF),
                  Color(0xFFBFE3FF),
                  Color(0xFFE6F5FF),
                ],
        ).createShader(Offset.zero & size),
    );

    _drawText(
      canvas,
      'Lake\nMichigan',
      Offset(size.width * 0.80, size.height * 0.32),
      color: isNight ? const Color(0xFF47AFFF) : const Color(0xFF2E75B8),
      fontSize: 14,
      weight: FontWeight.w800,
      align: TextAlign.center,
    );
  }

  void _drawChicagoGrid(Canvas canvas, Size size) {
    final Paint minor = Paint()
      ..color = (isNight ? const Color(0xFF8795A8) : const Color(0xFF9EACBA))
          .withOpacity(isNight ? 0.15 : 0.34)
      ..strokeWidth = 0.75;
    final Paint major = Paint()
      ..color = (isNight ? const Color(0xFFFF58F3) : const Color(0xFF59718C))
          .withOpacity(isNight ? 0.25 : 0.42)
      ..strokeWidth = 1.0;

    final double left = size.width * 0.03;
    final double right = size.width * 0.72;
    final double top = size.height * 0.13;
    final double bottom = size.height * 0.95;

    for (int i = 0; i < 15; i++) {
      final double x = left + (right - left) * i / 14;
      canvas.drawLine(
        Offset(x, top),
        Offset(x + size.width * 0.08, bottom),
        i % 4 == 0 ? major : minor,
      );
    }

    for (int i = 0; i < 22; i++) {
      final double y = top + (bottom - top) * i / 21;
      canvas.drawLine(
        Offset(left, y),
        Offset(right, y - size.height * 0.035),
        i % 5 == 0 ? major : minor,
      );
    }
  }

  void _drawMainRoutes(Canvas canvas, Size size) {
    final Paint routeBlue = Paint()
      ..color = (isNight ? const Color(0xFF2D9BFF) : const Color(0xFF387DBF))
          .withOpacity(isNight ? 0.72 : 0.58)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.1
      ..strokeCap = StrokeCap.round;
    final Paint routeMagenta = Paint()
      ..color = (isNight ? const Color(0xFFFF58F3) : const Color(0xFF8B6EA8))
          .withOpacity(isNight ? 0.55 : 0.44)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;

    final Path lakeShore = Path()
      ..moveTo(size.width * 0.72, size.height * 0.08)
      ..cubicTo(
        size.width * 0.64,
        size.height * 0.30,
        size.width * 0.75,
        size.height * 0.52,
        size.width * 0.68,
        size.height * 0.92,
      );
    canvas.drawPath(lakeShore, routeBlue);

    final Path westRoute = Path()
      ..moveTo(size.width * 0.12, size.height * 0.18)
      ..cubicTo(
        size.width * 0.23,
        size.height * 0.36,
        size.width * 0.22,
        size.height * 0.58,
        size.width * 0.35,
        size.height * 0.84,
      );
    canvas.drawPath(westRoute, routeMagenta);

    final Path centerRoute = Path()
      ..moveTo(size.width * 0.45, size.height * 0.12)
      ..cubicTo(
        size.width * 0.50,
        size.height * 0.36,
        size.width * 0.45,
        size.height * 0.60,
        size.width * 0.57,
        size.height * 0.90,
      );
    canvas.drawPath(centerRoute, routeMagenta);
  }

  void _drawLabels(Canvas canvas, Size size) {
    final Color neighborhood =
        isNight ? const Color(0xFFFF8DF7) : const Color(0xFF445466);
    _drawText(
      canvas,
      'CHICAGO',
      Offset(size.width * 0.34, size.height * 0.46),
      color: neighborhood.withOpacity(isNight ? 0.42 : 0.38),
      fontSize: 30,
      weight: FontWeight.w900,
    );
    _drawText(
      canvas,
      'Lincoln Park',
      Offset(size.width * 0.42, size.height * 0.20),
      color: neighborhood,
    );
    _drawText(
      canvas,
      'Wicker Park',
      Offset(size.width * 0.31, size.height * 0.34),
      color: neighborhood,
    );
    _drawText(
      canvas,
      'West Loop',
      Offset(size.width * 0.34, size.height * 0.61),
      color: neighborhood,
    );
    _drawText(
      canvas,
      'South Loop',
      Offset(size.width * 0.54, size.height * 0.68),
      color: neighborhood,
    );
    _drawText(
      canvas,
      'Hyde Park',
      Offset(size.width * 0.50, size.height * 0.84),
      color: neighborhood,
    );
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset offset, {
    required Color color,
    double fontSize = 10,
    FontWeight weight = FontWeight.w800,
    TextAlign align = TextAlign.left,
  }) {
    final TextPainter painter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: align,
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color.withOpacity(isNight ? 0.76 : 0.88),
          fontSize: fontSize,
          fontWeight: weight,
          letterSpacing: 0,
          shadows: isNight
              ? [
                  Shadow(
                    color: color.withOpacity(0.36),
                    blurRadius: 8,
                  ),
                ]
              : null,
        ),
      ),
    )..layout(maxWidth: 140);
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _ChicagoMapPainter oldDelegate) {
    return oldDelegate.isNight != isNight;
  }
}

String _eventTitle(EventModel event) {
  final String title = (event.title ?? '').trim();
  return title.isEmpty ? 'Free2B event' : title;
}

String _eventTime(EventModel event) {
  final DateTime? parsed = EventDateUtils.parseEventDateTime(event.startDate);
  if (parsed == null) {
    return 'Time coming soon';
  }
  return DateFormat('EEE, MMM d - h:mm a').format(parsed);
}

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/utils/app_colors.dart';
import 'package:flutter_template/utils/app_string.dart';
import 'package:flutter_template/widget/common_text.dart';
import 'package:get/get.dart';

class MapScreen extends StatelessWidget {
  MapScreen({super.key});

  final List<_MapEvent> _events = const [
    _MapEvent(
      title: 'House Music All Night Long',
      category: 'Music',
      time: 'Fri, Jul 24 - 10:00 PM',
      neighborhood: 'Logan Square',
      attending: '3 friends attending',
      color: Color(0xFF24D768),
      icon: Icons.music_note_rounded,
      alignment: Alignment(-0.63, -0.28),
      size: _CalloutSize.large,
    ),
    _MapEvent(
      title: 'Summer Concert at Millennium Park',
      category: 'Music',
      time: 'Fri, Jul 24 - 1:00 PM',
      neighborhood: 'Loop',
      attending: 'Matthew, Julie + 4 are attending',
      color: Color(0xFFFF5CEF),
      icon: Icons.music_note_rounded,
      alignment: Alignment(0.34, -0.48),
      size: _CalloutSize.large,
    ),
    _MapEvent(
      title: 'Movies in the Park',
      category: 'Film',
      time: 'Fri, Jul 24 - 8:30 PM',
      neighborhood: 'Pretty in Pink',
      attending: '8 attending',
      color: Color(0xFF139CFF),
      icon: Icons.videocam_rounded,
      alignment: Alignment(0.75, 0.08),
      size: _CalloutSize.medium,
    ),
    _MapEvent(
      title: 'Teen Open Mic Night',
      category: 'Open Mic',
      time: 'Sat, Jul 25 - 6:00 PM',
      neighborhood: 'West Loop',
      attending: 'Ari + 2 attending',
      color: Color(0xFFC455FF),
      icon: Icons.mic_rounded,
      alignment: Alignment(-0.27, 0.23),
      size: _CalloutSize.medium,
    ),
    _MapEvent(
      title: 'Art Workshop Create & Connect',
      category: 'Art',
      time: 'Sat, Jul 26 - 1:00 PM',
      neighborhood: 'Pilsen',
      attending: '6 attending',
      color: Color(0xFFFF7D1A),
      icon: Icons.palette_rounded,
      alignment: Alignment(-0.73, 0.66),
      size: _CalloutSize.medium,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: _ChicagoNightMapPainter(),
              ),
            ),
            Positioned(
              top: 12.h,
              left: 16.w,
              right: 16.w,
              child: _TopMapControls(),
            ),
            Positioned(
              top: 72.h,
              left: 16.w,
              right: 16.w,
              child: _CategoryRail(),
            ),
            Positioned(
              top: 116.h,
              left: 0,
              right: 0,
              bottom: 130.h,
              child: Stack(
                children: [
                  for (final event in _events)
                    Align(
                      alignment: event.alignment,
                      child: _EventCallout(event: event),
                    ),
                  const Align(
                    alignment: Alignment(0.20, 0.72),
                    child: _YouAreHerePin(),
                  ),
                  Align(
                    alignment: const Alignment(-0.70, -0.70),
                    child: _SmallMapPin(
                      color: const Color(0xFFC455FF),
                      icon: Icons.theater_comedy_rounded,
                    ),
                  ),
                  Align(
                    alignment: const Alignment(-0.42, 0.02),
                    child: _SmallMapPin(
                      color: const Color(0xFFC455FF),
                      icon: Icons.music_note_rounded,
                    ),
                  ),
                  Align(
                    alignment: const Alignment(0.18, -0.18),
                    child: _SmallMapPin(
                      color: const Color(0xFF24D768),
                      icon: Icons.groups_rounded,
                    ),
                  ),
                  Align(
                    alignment: const Alignment(0.55, 0.62),
                    child: _SmallMapPin(
                      color: const Color(0xFFC455FF),
                      icon: Icons.theater_comedy_rounded,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 14.w,
              right: 14.w,
              bottom: 18.h,
              child: const _TodayEventTray(),
            ),
          ],
        ),
      ),
    );
  }
}

class _TopMapControls extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            _RoundIconButton(icon: Icons.search_rounded),
            const Spacer(),
            CommonText(
              text: 'Free2B',
              color: const Color(0xFFFF63F7),
              fontSize: 26.sp,
              fontWeight: FontWeight.w800,
            ),
            const Spacer(),
            _RoundIconButton(icon: Icons.tune_rounded),
          ],
        ),
      ],
    );
  }
}

class _CategoryRail extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<String> labels = [
      'All',
      'Music',
      'Art',
      'Theatre',
      'Film',
      'Dance',
      'More',
    ];

    return SizedBox(
      height: 40.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: labels.length,
        separatorBuilder: (_, __) => 8.w.horizontalSpace,
        itemBuilder: (context, index) {
          final bool selected = index == 0;
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 17.w),
            decoration: BoxDecoration(
              color:
                  selected ? const Color(0xFF5B23E5) : const Color(0xE91B1E2A),
              borderRadius: BorderRadius.circular(22.r),
              border: Border.all(color: Colors.white.withOpacity(0.08)),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF733CFF).withOpacity(0.32),
                        blurRadius: 16.r,
                      ),
                    ]
                  : null,
            ),
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CommonText(
                    text: labels[index],
                    color: AppColors.textColor,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                  ),
                  if (labels[index] == 'More') ...[
                    5.w.horizontalSpace,
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: AppColors.textColor,
                      size: 16.sp,
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 42.w,
      width: 42.w,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.34),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: AppColors.textColor,
        size: 25.sp,
      ),
    );
  }
}

class _EventCallout extends StatelessWidget {
  const _EventCallout({required this.event});

  final _MapEvent event;

  @override
  Widget build(BuildContext context) {
    final bool large = event.size == _CalloutSize.large;
    final double width = large ? 178.w : 158.w;

    return SizedBox(
      width: width,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (event.title.contains('Summer'))
            _InitialStack(color: event.color).paddingOnly(bottom: 4.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.62),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: event.color, width: 1.3),
              boxShadow: [
                BoxShadow(
                  color: event.color.withOpacity(0.45),
                  blurRadius: 22.r,
                  spreadRadius: 1.r,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(event.icon, color: event.color, size: 20.sp),
                    8.w.horizontalSpace,
                    Expanded(
                      child: CommonText(
                        text: event.title,
                        color: AppColors.textColor,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w800,
                        maxLine: 2,
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
                8.h.verticalSpace,
                CommonText(
                  text: event.time,
                  color: AppColors.textLightColor,
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  maxLine: 1,
                  softWrap: false,
                ),
                if (large) ...[
                  8.h.verticalSpace,
                  CommonText(
                    text: event.attending,
                    color: AppColors.textColor,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    maxLine: 2,
                    softWrap: true,
                  ),
                ],
              ],
            ),
          ),
          _GlowStem(color: event.color),
        ],
      ),
    );
  }
}

class _InitialStack extends StatelessWidget {
  const _InitialStack({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    final List<String> initials = ['M', 'J', 'A'];
    return SizedBox(
      height: 34.w,
      width: 92.w,
      child: Stack(
        children: [
          for (int index = 0; index < initials.length; index++)
            Positioned(
              left: index * 22.w,
              child: Container(
                height: 34.w,
                width: 34.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF18151F),
                  shape: BoxShape.circle,
                  border: Border.all(color: color, width: 1.5),
                ),
                child: Center(
                  child: CommonText(
                    text: initials[index],
                    color: AppColors.textColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          Positioned(
            left: 64.w,
            child: Container(
              height: 34.w,
              width: 34.w,
              decoration: BoxDecoration(
                color: const Color(0xFF5B23E5),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1.2),
              ),
              child: Center(
                child: CommonText(
                  text: '3',
                  color: AppColors.textColor,
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
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
          height: 38.h,
          width: 3.w,
          decoration: BoxDecoration(
            color: color,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.75),
                blurRadius: 14.r,
                spreadRadius: 2.r,
              ),
            ],
          ),
        ),
        Container(
          height: 14.w,
          width: 30.w,
          decoration: BoxDecoration(
            border: Border.all(color: color, width: 2),
            borderRadius: BorderRadius.circular(50.r),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.65),
                blurRadius: 18.r,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SmallMapPin extends StatelessWidget {
  const _SmallMapPin({required this.color, required this.icon});

  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          height: 38.w,
          width: 38.w,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.48),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.56),
                blurRadius: 18.r,
                spreadRadius: 1.r,
              ),
            ],
          ),
          child: Icon(icon, color: color, size: 20.sp),
        ),
        _GlowStem(color: color),
      ],
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
          padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 7.h),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: Colors.white.withOpacity(0.50)),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.55),
                blurRadius: 18.r,
              ),
            ],
          ),
          child: CommonText(
            text: 'You are here',
            color: AppColors.textColor,
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        _GlowStem(color: color),
      ],
    );
  }
}

class _TodayEventTray extends StatelessWidget {
  const _TodayEventTray();

  @override
  Widget build(BuildContext context) {
    final List<_TrayEvent> trayEvents = const [
      _TrayEvent(
        label: 'Concert',
        colors: [Color(0xFF7F20FF), Color(0xFFFF4FE3)],
        icon: Icons.music_note_rounded,
      ),
      _TrayEvent(
        label: 'Murals',
        colors: [Color(0xFF32221A), Color(0xFFFF852C)],
        icon: Icons.brush_rounded,
      ),
      _TrayEvent(
        label: 'Film',
        colors: [Color(0xFF163B6D), Color(0xFF50B9FF)],
        icon: Icons.movie_filter_rounded,
      ),
      _TrayEvent(
        label: 'Dance',
        colors: [Color(0xFF311322), Color(0xFFFFB04A)],
        icon: Icons.nightlife_rounded,
      ),
      _TrayEvent(
        label: 'Gallery',
        colors: [Color(0xFF272727), Color(0xFFE4DED1)],
        icon: Icons.museum_rounded,
      ),
    ];

    return Container(
      padding: EdgeInsets.fromLTRB(14.w, 12.h, 14.w, 14.h),
      decoration: BoxDecoration(
        color: const Color(0xF20C0D13),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: Colors.white.withOpacity(0.14)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.45),
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
              width: 46.w,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(99.r),
              ),
            ),
          ),
          10.h.verticalSpace,
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(
                      text: 'Today - Fri, Jul 24',
                      color: AppColors.textColor,
                      fontSize: 17.sp,
                      fontWeight: FontWeight.w800,
                    ),
                    2.h.verticalSpace,
                    CommonText(
                      text: '32 events around Chicago',
                      color: AppColors.textLightColor,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.close_rounded,
                color: AppColors.textLightColor,
                size: 24.sp,
              ),
            ],
          ),
          12.h.verticalSpace,
          SizedBox(
            height: 72.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: trayEvents.length,
              separatorBuilder: (_, __) => 10.w.horizontalSpace,
              itemBuilder: (context, index) {
                final _TrayEvent event = trayEvents[index];
                return Container(
                  width: 104.w,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: event.colors,
                    ),
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.white.withOpacity(0.10)),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -8.w,
                        top: -8.h,
                        child: Icon(
                          event.icon,
                          color: Colors.white.withOpacity(0.20),
                          size: 54.sp,
                        ),
                      ),
                      Positioned(
                        left: 9.w,
                        right: 9.w,
                        bottom: 8.h,
                        child: CommonText(
                          text: event.label,
                          color: AppColors.textColor,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w800,
                          maxLine: 1,
                          softWrap: false,
                        ),
                      ),
                    ],
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

class _ChicagoNightMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;
    final Paint backgroundPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF050712),
          Color(0xFF0A0920),
          Color(0xFF07090F),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, backgroundPaint);

    _drawLake(canvas, size);
    _drawGrid(canvas, size);
    _drawExpressways(canvas, size);
    _drawLabels(canvas, size);
    _drawCityTitle(canvas, size);
  }

  void _drawLake(Canvas canvas, Size size) {
    final Path lake = Path()
      ..moveTo(size.width * 0.70, 0)
      ..cubicTo(
        size.width * 0.63,
        size.height * 0.26,
        size.width * 0.80,
        size.height * 0.42,
        size.width * 0.70,
        size.height * 0.64,
      )
      ..cubicTo(
        size.width * 0.62,
        size.height * 0.84,
        size.width * 0.80,
        size.height,
        size.width * 0.74,
        size.height,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(size.width, 0)
      ..close();
    final Paint lakePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [
          Color(0x00136887),
          Color(0xCC063D69),
          Color(0xFF061A31),
        ],
      ).createShader(Offset.zero & size);
    canvas.drawPath(lake, lakePaint);

    final TextPainter lakeLabel = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      text: TextSpan(
        text: 'Lake\nMichigan\n~~~~',
        style: TextStyle(
          color: const Color(0xFF2EA7FF).withOpacity(0.86),
          fontSize: 16,
          fontWeight: FontWeight.w700,
          height: 1.25,
        ),
      ),
    )..layout(maxWidth: 120);
    lakeLabel.paint(
      canvas,
      Offset(size.width * 0.78, size.height * 0.30),
    );
  }

  void _drawGrid(Canvas canvas, Size size) {
    final Paint minor = Paint()
      ..color = const Color(0xFF7A28FF).withOpacity(0.18)
      ..strokeWidth = 0.8;
    final Paint major = Paint()
      ..color = const Color(0xFFFF4EF1).withOpacity(0.42)
      ..strokeWidth = 1.15;
    final Paint cyan = Paint()
      ..color = const Color(0xFF1D8CFF).withOpacity(0.28)
      ..strokeWidth = 1;

    for (double x = -size.width * 0.20;
        x < size.width * 0.78;
        x += size.width * 0.055) {
      canvas.drawLine(
        Offset(x, size.height * 0.13),
        Offset(x + size.width * 0.26, size.height),
        minor,
      );
    }

    for (double y = size.height * 0.17;
        y < size.height;
        y += size.height * 0.035) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width * 0.76, y + size.height * 0.04),
        y % (size.height * 0.14) < 1 ? major : minor,
      );
    }

    for (double y = size.height * 0.20;
        y < size.height;
        y += size.height * 0.12) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width * 0.72, y - size.height * 0.06),
        cyan,
      );
    }

    final Paint dots = Paint()..color = const Color(0xFFFF8747).withOpacity(0.55);
    for (int index = 0; index < 120; index++) {
      final double x =
          ((index * 37) % 100) / 100 * size.width * 0.72 + size.width * 0.02;
      final double y =
          size.height * 0.18 + ((index * 53) % 100) / 100 * size.height * 0.72;
      canvas.drawCircle(Offset(x, y), 0.8, dots);
    }
  }

  void _drawExpressways(Canvas canvas, Size size) {
    final Paint pinkRoad = Paint()
      ..color = const Color(0xFFFF4EF1).withOpacity(0.64)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;
    final Paint blueRoad = Paint()
      ..color = const Color(0xFF168BFF).withOpacity(0.80)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2
      ..strokeCap = StrokeCap.round;

    final Path lakeShore = Path()
      ..moveTo(size.width * 0.73, size.height * 0.05)
      ..cubicTo(
        size.width * 0.62,
        size.height * 0.32,
        size.width * 0.78,
        size.height * 0.52,
        size.width * 0.69,
        size.height * 0.94,
      );
    canvas.drawPath(lakeShore, blueRoad);

    final Path westRoad = Path()
      ..moveTo(size.width * 0.05, size.height * 0.18)
      ..cubicTo(
        size.width * 0.22,
        size.height * 0.34,
        size.width * 0.18,
        size.height * 0.55,
        size.width * 0.30,
        size.height * 0.78,
      );
    canvas.drawPath(westRoad, pinkRoad);

    final Path centerRoad = Path()
      ..moveTo(size.width * 0.36, size.height * 0.10)
      ..cubicTo(
        size.width * 0.45,
        size.height * 0.35,
        size.width * 0.42,
        size.height * 0.60,
        size.width * 0.55,
        size.height * 0.94,
      );
    canvas.drawPath(centerRoad, pinkRoad);
  }

  void _drawLabels(Canvas canvas, Size size) {
    final TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
    _drawLabel(canvas, painter, 'LINCOLN\nPARK',
        Offset(size.width * 0.39, size.height * 0.20));
    _drawLabel(canvas, painter, 'WICKER\nPARK',
        Offset(size.width * 0.42, size.height * 0.34));
    _drawLabel(canvas, painter, 'LOGAN\nSQUARE',
        Offset(size.width * 0.05, size.height * 0.43));
    _drawLabel(canvas, painter, 'WEST\nLOOP',
        Offset(size.width * 0.35, size.height * 0.65));
    _drawLabel(canvas, painter, 'SOUTH\nLOOP',
        Offset(size.width * 0.58, size.height * 0.61));
    _drawLabel(canvas, painter, 'HYDE PARK',
        Offset(size.width * 0.65, size.height * 0.77));

    _drawShield(canvas, '90/94', Offset(size.width * 0.27, size.height * 0.28));
    _drawShield(canvas, '55', Offset(size.width * 0.06, size.height * 0.58));
  }

  void _drawLabel(
    Canvas canvas,
    TextPainter painter,
    String text,
    Offset offset,
  ) {
    painter.text = TextSpan(
      text: text,
      style: TextStyle(
        color: const Color(0xFFFF64F3).withOpacity(0.72),
        fontSize: 11,
        fontWeight: FontWeight.w800,
        height: 1.05,
      ),
    );
    painter.layout();
    painter.paint(canvas, offset);
  }

  void _drawShield(Canvas canvas, String label, Offset center) {
    final RRect rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 42, height: 26),
      const Radius.circular(12),
    );
    canvas.drawRRect(
      rect,
      Paint()..color = const Color(0xFF173B8F).withOpacity(0.85),
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..color = Colors.white.withOpacity(0.80)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.4,
    );
    final TextPainter painter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      text: TextSpan(
        text: label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    )..layout(maxWidth: 42);
    painter.paint(
      canvas,
      center - Offset(painter.width / 2, painter.height / 2),
    );
  }

  void _drawCityTitle(Canvas canvas, Size size) {
    final TextPainter painter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
      text: TextSpan(
        text: 'CHICAGO',
        style: TextStyle(
          color: const Color(0xFFFF5CEF).withOpacity(0.86),
          fontSize: 40,
          fontWeight: FontWeight.w900,
          letterSpacing: 0,
          shadows: [
            Shadow(
              color: const Color(0xFFFF5CEF).withOpacity(0.65),
              blurRadius: 18,
            ),
          ],
        ),
      ),
    )..layout(maxWidth: size.width);
    painter.paint(
      canvas,
      Offset(size.width * 0.50 - painter.width / 2, size.height * 0.47),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MapEvent {
  const _MapEvent({
    required this.title,
    required this.category,
    required this.time,
    required this.neighborhood,
    required this.attending,
    required this.color,
    required this.icon,
    required this.alignment,
    required this.size,
  });

  final String title;
  final String category;
  final String time;
  final String neighborhood;
  final String attending;
  final Color color;
  final IconData icon;
  final Alignment alignment;
  final _CalloutSize size;
}

class _TrayEvent {
  const _TrayEvent({
    required this.label,
    required this.colors,
    required this.icon,
  });

  final String label;
  final List<Color> colors;
  final IconData icon;
}

enum _CalloutSize { medium, large }

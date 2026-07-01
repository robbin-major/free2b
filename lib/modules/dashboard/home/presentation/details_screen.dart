import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_template/modules/dashboard/home/controller/details_controller.dart';
import 'package:flutter_template/utils/app_colors.dart';
import 'package:flutter_template/utils/app_string.dart';
import 'package:flutter_template/utils/assets.dart';
import 'package:flutter_template/utils/common_service/app_pref_service.dart';
import 'package:flutter_template/utils/event_date_utils.dart';
import 'package:flutter_template/utils/navigation_utils/navigation.dart';
import 'package:flutter_template/widget/common_text.dart';
import 'package:flutter_template/widget/event_image.dart';
import 'package:flutter_template/widget/login_popup.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

class DetailsScreen extends StatelessWidget {
  DetailsScreen({super.key});

  final DetailController _detailController = Get.put(DetailController());

  @override
  Widget build(BuildContext context) {
    final bool hasEnded = _hasEventEnded();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHero(context),
              _buildBody(context, hasEnded: hasEnded),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHero(BuildContext context) {
    final String title = _detailController.eventModel.title ?? '';

    return SizedBox(
      height: 430.h,
      width: Get.width,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Hero(
            tag: _detailController.eventModel.image ?? '',
            child: EventImage(
              width: Get.width,
              height: 430.h,
              imageUrl: _detailController.eventModel.image,
              fit: BoxFit.cover,
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xB0000000),
                  Color(0x22000000),
                  Color(0xEE0F0F10),
                ],
                stops: [0.0, 0.42, 1.0],
              ),
            ),
          ),
          Positioned(
            top: 16.h,
            left: 16.w,
            right: 16.w,
            child: Row(
              children: [
                _buildCircleIconButton(
                  icon: Icons.arrow_back,
                  onTap: Navigation.pop,
                ),
                const Spacer(),
                if (_detailController.eventModel.uid !=
                    AppPrefService.getUserUid())
                  Obx(
                    () => _buildCircleIconButton(
                      svgAsset: _isBookmarked()
                          ? IconAsset.bookMarkDoneIcon
                          : IconAsset.bookMarkIcon,
                      onTap: () => _toggleBookmark(context),
                    ),
                  ).paddingOnly(right: 10.w),
                _buildCircleIconButton(
                  svgAsset: IconAsset.shareIcon,
                  onTap: _shareEvent,
                ),
              ],
            ),
          ),
          Positioned(
            left: 18.w,
            right: 18.w,
            bottom: 24.h,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    _buildBadge(_categoryLabel()),
                    _buildBadge('Free', isAccent: true),
                  ],
                ).paddingOnly(bottom: 12.h),
                CommonText(
                  text: title,
                  fontSize: 30.sp,
                  fontWeight: FontWeight.w800,
                  maxLine: 3,
                  overflow: TextOverflow.ellipsis,
                  shadows: const [
                    Shadow(
                      color: Colors.black87,
                      offset: Offset(0, 1),
                      blurRadius: 10,
                    ),
                  ],
                ).paddingOnly(bottom: 12.h),
                _buildMetaRow(
                  icon: Icons.calendar_month_outlined,
                  text: _eventDateTimeText(),
                ).paddingOnly(bottom: 8.h),
                GestureDetector(
                  onTap: _openMapLocation,
                  child: _buildMetaRow(
                    icon: Icons.location_on_outlined,
                    text: _locationText(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, {required bool hasEnded}) {
    return Container(
      width: Get.width,
      decoration: BoxDecoration(
        color: AppColors.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildAttendingPreview(),
          if (!hasEnded)
            Obx(
              () => _buildPrimaryAttendingButton(context),
            ).paddingOnly(top: 14.h),
          if (hasEnded)
            _buildEndedPill().paddingOnly(top: 14.h),
          if (!hasEnded)
            Row(
              children: [
                Expanded(
                  child: _buildSecondaryAction(
                    icon: Icons.calendar_month_outlined,
                    label: AppString.addToCalendar,
                    onTap: () => _showCalendarIntegrationMessage(context),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: _buildSecondaryAction(
                    icon: Icons.ios_share_outlined,
                    label: 'Share Event',
                    onTap: _shareEvent,
                  ),
                ),
              ],
            ).paddingOnly(top: 14.h),
          if (hasEnded)
            _buildSecondaryAction(
              icon: Icons.ios_share_outlined,
              label: 'Share Event',
              onTap: _shareEvent,
            ).paddingOnly(top: 14.h),
          DefaultTabController(
            length: 3,
            child: Column(
              children: [
                Container(
                  height: 48.h,
                  margin: EdgeInsets.only(top: 18.h, bottom: 16.h),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundLightColor,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.dividerColor),
                  ),
                  child: TabBar(
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.r),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF4FB8), Color(0xFFB45CFF)],
                      ),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: AppColors.textLightColor,
                    labelStyle: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
                    ),
                    unselectedLabelStyle: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    tabs: const [
                      Tab(text: 'About'),
                      Tab(text: 'Discussion'),
                      Tab(text: 'Memories'),
                    ],
                  ),
                ),
                SizedBox(
                  height: 330.h,
                  child: TabBarView(
                    children: [
                      _buildAboutTab(),
                      _buildPlanningTab(
                        icon: Icons.forum_outlined,
                        title: 'Event discussion is coming later',
                        body:
                            'Future event threads will need reporting, filters, and admin review before public posting goes live.',
                      ),
                      _buildPlanningTab(
                        icon: Icons.photo_library_outlined,
                        title: 'Future memories will live here',
                        body:
                            'A later version can let people revisit photos, reactions, and moments after an event, with privacy controls first.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ).paddingOnly(
        left: 18.w,
        top: 18.h,
        right: 18.w,
        bottom: 28.h,
      ),
    );
  }

  Widget _buildCircleIconButton({
    IconData? icon,
    String? svgAsset,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Ink(
          height: 42.h,
          width: 42.h,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.48),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.18)),
          ),
          child: Center(
            child: svgAsset != null
                ? SvgPicture.asset(
                    svgAsset,
                    height: 20.h,
                    width: 20.h,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  )
                : Icon(icon, color: Colors.white, size: 22.sp),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String label, {bool isAccent = false}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: isAccent ? const Color(0xFF31E6A0) : const Color(0xFFFF4FB8),
        borderRadius: BorderRadius.circular(999.r),
        boxShadow: [
          BoxShadow(
            color: (isAccent ? const Color(0xFF31E6A0) : const Color(0xFFFF4FB8))
                .withOpacity(0.24),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CommonText(
        text: label,
        color: isAccent ? Colors.black : Colors.white,
        fontSize: 12.sp,
        fontWeight: FontWeight.w800,
      ),
    );
  }

  Widget _buildMetaRow({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.white.withOpacity(0.86), size: 18.sp)
            .paddingOnly(right: 8.w, top: 1.h),
        Expanded(
          child: CommonText(
            text: text,
            color: Colors.white.withOpacity(0.9),
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            maxLine: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildAttendingPreview() {
    final int attendingCount =
        _detailController.userData.value?.attending?.length ?? 0;
    final String previewText = attendingCount > 0
        ? '$attendingCount attending'
        : 'Be one of the first to mark yourself attending';

    return Container(
      padding: EdgeInsets.all(14.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundLightColor,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.dividerColor),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 74.w,
            height: 32.h,
            child: Stack(
              children: List.generate(3, (index) {
                return Positioned(
                  left: index * 20.w,
                  child: Container(
                    height: 32.h,
                    width: 32.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFF4FB8).withOpacity(0.9 - index * 0.1),
                          const Color(0xFF31E6A0).withOpacity(0.9 - index * 0.1),
                        ],
                      ),
                      border: Border.all(
                        color: AppColors.backgroundLightColor,
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: CommonText(
                        text: ['F', '2', 'B'][index],
                        color: Colors.black,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: CommonText(
              text: previewText,
              color: AppColors.textLightColor,
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              maxLine: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryAttendingButton(BuildContext context) {
    final bool isAttending = _isAttendingEvent();

    return SizedBox(
      width: Get.width,
      height: 50.h,
      child: ElevatedButton.icon(
        onPressed: () => _toggleAttending(context),
        icon: Icon(
          isAttending ? Icons.check_circle : Icons.check_circle_outline,
          size: 20.sp,
        ),
        label: Text(
          isAttending ? AppString.attending : AppString.imAttending,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
          ),
        ),
        style: ElevatedButton.styleFrom(
          foregroundColor: isAttending ? Colors.black : Colors.white,
          backgroundColor:
              isAttending ? const Color(0xFF31E6A0) : const Color(0xFFFF4FB8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: onTap,
        child: Ink(
          height: 48.h,
          decoration: BoxDecoration(
            color: const Color(0xFF191A22),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.dividerColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFFFF7BD5), size: 18.sp),
              Flexible(
                child: CommonText(
                  text: label,
                  color: Colors.white,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w800,
                  maxLine: 1,
                  overflow: TextOverflow.ellipsis,
                ).paddingOnly(left: 8.w),
              ),
            ],
          ).paddingSymmetric(horizontal: 8.w),
        ),
      ),
    );
  }

  Widget _buildEndedPill() {
    return Container(
      width: Get.width,
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.disableButtonColor.withOpacity(0.16),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.disableButtonColor.withOpacity(0.4)),
      ),
      child: CommonText(
        text: AppString.eventHasPassed,
        color: Colors.white,
        fontWeight: FontWeight.w800,
        fontSize: 13.sp,
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildAboutTab() {
    final List<String> descriptions = _detailController.eventModel.description ?? [];

    if (descriptions.isEmpty) {
      return _buildPlanningTab(
        icon: Icons.info_outline,
        title: 'More details coming soon',
        body: 'Check back for event notes, schedule details, and accessibility information.',
      );
    }

    return ListView.builder(
      padding: EdgeInsets.zero,
      itemCount: descriptions.length,
      itemBuilder: (context, index) {
        final String value = descriptions[index];

        return Padding(
          padding: EdgeInsets.only(bottom: 14.h),
          child: RichText(
            text: TextSpan(
              children: _detailController.getStyledText(text: value),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPlanningTab({
    required IconData icon,
    required String title,
    required String body,
  }) {
    return Container(
      width: Get.width,
      padding: EdgeInsets.all(18.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundLightColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.dividerColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFFFF7BD5), size: 34.sp),
          CommonText(
            text: title,
            color: Colors.white,
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            textAlign: TextAlign.center,
          ).paddingOnly(top: 12.h, bottom: 8.h),
          CommonText(
            text: body,
            color: AppColors.textLightColor,
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  bool _hasEventEnded() {
    final DateTime? eventDateTime =
        EventDateUtils.parseEventDateTime(
              _detailController.eventModel.endDate,
            ) ??
            EventDateUtils.parseEventDateTime(
              _detailController.eventModel.startDate,
            );

    return eventDateTime != null &&
        EventDateUtils.hasEventEnded(eventDateTime);
  }

  String _eventDateTimeText() {
    final String date = _formatEventDate(_detailController.eventModel.startDate);
    final String startTime = _eventTimeText(_detailController.eventModel.startDate);
    final String endTime = _eventTimeText(_detailController.eventModel.endDate);

    if (startTime == '--' && endTime == '--') {
      return date;
    }

    if (endTime != '--' && endTime != startTime) {
      return '$date · $startTime - $endTime';
    }

    return '$date · $startTime';
  }

  String _formatEventDate(String? value) {
    final DateTime? parsed = EventDateUtils.parseEventDateTime(value);

    if (parsed == null) {
      return value?.trim().isNotEmpty == true ? value!.trim() : '--';
    }

    return '${DateFormat('MMMM').format(parsed)} ${parsed.day}${_ordinalSuffix(parsed.day)}, ${parsed.year}';
  }

  String _ordinalSuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }

    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  String _eventTimeText(String? startDate) {
    final DateTime? parsed = EventDateUtils.parseEventDateTime(startDate);

    if (parsed == null || !(startDate ?? '').trim().contains(':')) {
      return '--';
    }

    return DateFormat('hh:mm a').format(parsed);
  }

  String _locationText() {
    final List<String> parts = [
      _detailController.eventModel.aptSuiteOther,
      _detailController.eventModel.address,
      _detailController.eventModel.city,
      _detailController.eventModel.state,
    ]
        .whereType<String>()
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .toList();

    return parts.isEmpty ? 'Location TBA' : parts.join(', ');
  }

  String _categoryLabel() {
    final String categoryType = _detailController.eventModel.categoryType ?? '';

    if (categoryType.trim().isNotEmpty) {
      return categoryType.trim();
    }

    final String categoryName =
        _detailController.eventModel.category?.isNotEmpty == true
            ? _detailController.eventModel.category!.first.categoryName ?? ''
            : '';

    return categoryName.trim().isNotEmpty ? categoryName.trim() : 'Free2B Event';
  }

  bool _isBookmarked() {
    return _detailController.userData.value?.bookmark?.any(
          (element) => element == _detailController.eventModel.eventID,
        ) ??
        false;
  }

  Future<void> _toggleBookmark(BuildContext context) async {
    final String userID = AppPrefService.getUserUid();
    final String eventId = _detailController.eventModel.eventID ?? '';

    _detailController.isBookMark.toggle();

    if (userID.isEmpty) {
      userLoginPopup(context);
      return;
    }

    if (eventId.isEmpty) {
      return;
    }

    if (_isBookmarked()) {
      _detailController.bookMarkId.remove(eventId);
    } else {
      _detailController.bookMarkId.add(eventId);
    }

    await _detailController.eventBookMark();
  }

  bool _isAttendingEvent() {
    final String eventId = _detailController.eventModel.eventID ?? '';

    return eventId.isNotEmpty &&
        (_detailController.userData.value?.attending?.contains(eventId) ??
            false);
  }

  Future<void> _toggleAttending(BuildContext context) async {
    final String userID = AppPrefService.getUserUid();
    final String eventId = _detailController.eventModel.eventID ?? '';

    if (userID.isEmpty) {
      userLoginPopup(context);
      return;
    }

    if (eventId.isEmpty) {
      return;
    }

    final bool isAttending =
        _detailController.attendingId.any((element) => element == eventId);

    if (isAttending) {
      _detailController.attendingId.remove(eventId);
    } else {
      _detailController.attendingId.add(eventId);
    }

    await _detailController.eventAttendance(
      eventId: eventId,
      attending: !isAttending,
    );
  }

  void _openMapLocation() {
    _detailController.getLatLngFromAddress(
      "${_detailController.eventModel.address} "
      "${_detailController.eventModel.city} "
      "${_detailController.eventModel.state} "
      "${_detailController.eventModel.country}",
    );
  }

  Future<void> _shareEvent() async {
    final String downloadUrl = 'https://appurl.io/UIg7_O0amY';
    final String title = _detailController.eventModel.title?.toUpperCase() ?? '';
    final String description =
        _detailController.eventModel.description?.join("\n") ?? '';

    final ShareParams params = ShareParams(
      subject: title,
      title: title,
      text: '**$title**\n\n'
          '$description\n\n'
          '✨ Find more free Chicago events on the Free2B app:\n'
          '👉🏾 $downloadUrl\n',
    );

    await SharePlus.instance.share(params);
  }

  void _showCalendarIntegrationMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text(
          AppString.calendarIntegrationComingSoon,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: const Color(0xFF1A1A1A),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}

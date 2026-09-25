import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_template/modules/dashboard/home/controller/home_controller.dart';
import 'package:flutter_template/modules/dashboard/home/model/event_model.dart';
import 'package:flutter_template/utils/app_colors.dart';
import 'package:flutter_template/utils/app_preferences.dart';
import 'package:flutter_template/utils/assets.dart';
import 'package:flutter_template/utils/common_service/app_pref_service.dart';
import 'package:flutter_template/utils/event_date_utils.dart';
import 'package:flutter_template/utils/navigation_utils/navigation.dart';
import 'package:flutter_template/utils/navigation_utils/routes.dart';
import 'package:flutter_template/widget/common_text.dart';
import 'package:flutter_template/widget/custom_loading_widget.dart';
import 'package:flutter_template/widget/event_image.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart' show DateFormat;

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  final HomeController _homeController = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _HomeHeader(onNotificationTap: () {}),
            _HomeSearch(controller: _homeController),
            Expanded(
              child: Obx(() {
                if (_homeController.isEventLoading.value) {
                  return const CustomLoadingWidget();
                }

                if (_homeController.isSearch.value) {
                  return _SearchResults(
                    events: _homeController.searchEventData.toList(),
                    onRefresh: _homeController.getEvent,
                    onTapEvent: _openEvent,
                  );
                }

                return _CuratedHome(
                  events: _homeController.filterEventData.toList(),
                  onRefresh: _homeController.getEvent,
                  onTapEvent: _openEvent,
                  onTapCategory: _searchCategory,
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _searchCategory(String category) {
    _homeController.textEditingController.text = category;
    _homeController.searchEvent(value: category);
  }

  void _openEvent(EventModel event) {
    Navigation.pushNamed(Routes.detailsScreen, arg: event);
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.onNotificationTap});

  final VoidCallback onNotificationTap;

  @override
  Widget build(BuildContext context) {
    final String displayName = _displayName();

    return Padding(
      padding: EdgeInsets.fromLTRB(18.w, 18.h, 14.w, 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: displayName.isEmpty
                ? CommonText(
                    text: 'Home',
                    color: AppColors.textPrimary,
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w700,
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText(
                        text: 'Welcome back',
                        color: AppColors.textSecondary,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                      ),
                      2.h.verticalSpace,
                      CommonText(
                        text: displayName,
                        color: AppColors.textPrimary,
                        fontSize: 25.sp,
                        fontWeight: FontWeight.w700,
                        maxLine: 1,
                      ),
                    ],
                  ),
          ),
          Material(
            color: AppColors.surface,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: onNotificationTap,
              child: SizedBox(
                height: 42.w,
                width: 42.w,
                child: Center(
                  child: SvgPicture.asset(
                    IconAsset.notificationIcon,
                    height: 22.w,
                    width: 22.w,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _displayName() {
    final String storedName = AppPrefService.getName().trim();
    if (storedName.isNotEmpty) return storedName;

    final user = AppPreference.getUser();
    return <String?>[user?.firstName, user?.lastName]
        .whereType<String>()
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .join(' ');
  }
}

class _HomeSearch extends StatelessWidget {
  const _HomeSearch({required this.controller});

  final HomeController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Padding(
        padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 16.h),
        child: Container(
          height: 50.h,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(15.r),
            border: Border.all(color: AppColors.border),
          ),
          child: TextField(
            controller: controller.textEditingController,
            onChanged: (value) => controller.searchEvent(value: value),
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: 'Search events or interests',
              hintStyle: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14.sp,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: AppColors.textSecondary,
                size: 21.sp,
              ),
              suffixIcon: controller.isSearch.value
                  ? IconButton(
                      onPressed: () {
                        controller.textEditingController.clear();
                        controller.searchEvent(value: '');
                      },
                      icon: Icon(
                        Icons.close_rounded,
                        color: AppColors.textSecondary,
                        size: 20.sp,
                      ),
                    )
                  : null,
              filled: false,
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 15.h),
            ),
          ),
        ),
      ),
    );
  }
}

class _CuratedHome extends StatelessWidget {
  const _CuratedHome({
    required this.events,
    required this.onRefresh,
    required this.onTapEvent,
    required this.onTapCategory,
  });

  final List<EventModel> events;
  final Future<void> Function() onRefresh;
  final ValueChanged<EventModel> onTapEvent;
  final ValueChanged<String> onTapCategory;

  @override
  Widget build(BuildContext context) {
    final List<EventModel> sortedEvents = _sortUpcoming(events);
    final EventModel? featured = _featuredEvent(sortedEvents);
    final List<EventModel> happeningSoon = sortedEvents
        .where((event) => !_sameEvent(event, featured))
        .take(10)
        .toList();
    final List<String> categories = _categoriesFrom(sortedEvents);

    if (featured == null) {
      return _EmptyHome(onRefresh: onRefresh);
    }

    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.surfaceElevated,
      onRefresh: onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 28.h),
            sliver: SliverList(
              delegate: SliverChildListDelegate.fixed([
                const _SectionHeading(
                  title: 'Featured this week',
                  subtitle: 'A timely pick from upcoming Free2B events',
                ),
                11.h.verticalSpace,
                _FeaturedEventCard(
                  event: featured,
                  onTap: () => onTapEvent(featured),
                ),
                if (happeningSoon.isNotEmpty) ...[
                  25.h.verticalSpace,
                  const _SectionHeading(
                    title: 'Happening soon',
                    subtitle: 'More ideas for your next outing',
                  ),
                  12.h.verticalSpace,
                  SizedBox(
                    height: 184.h,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: happeningSoon.length,
                      separatorBuilder: (_, __) => 12.w.horizontalSpace,
                      itemBuilder: (context, index) {
                        final EventModel event = happeningSoon[index];
                        return _SoonEventCard(
                          event: event,
                          onTap: () => onTapEvent(event),
                        );
                      },
                    ),
                  ),
                ],
                if (categories.isNotEmpty) ...[
                  25.h.verticalSpace,
                  const _SectionHeading(
                    title: 'Explore by interest',
                    subtitle: 'Browse what speaks to you',
                  ),
                  12.h.verticalSpace,
                  Wrap(
                    spacing: 8.w,
                    runSpacing: 8.h,
                    children: categories
                        .map(
                          (category) => _InterestChip(
                            label: category,
                            onTap: () => onTapCategory(category),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _SearchResults extends StatelessWidget {
  const _SearchResults({
    required this.events,
    required this.onRefresh,
    required this.onTapEvent,
  });

  final List<EventModel> events;
  final Future<void> Function() onRefresh;
  final ValueChanged<EventModel> onTapEvent;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return _EmptySearch(onRefresh: onRefresh);
    }

    final List<EventModel> sortedEvents = _sortUpcoming(events);
    return RefreshIndicator(
      color: AppColors.primary,
      backgroundColor: AppColors.surfaceElevated,
      onRefresh: onRefresh,
      child: ListView.separated(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 2.h, 16.w, 28.h),
        itemCount: sortedEvents.length + 1,
        separatorBuilder: (_, index) =>
            index == 0 ? 12.h.verticalSpace : 10.h.verticalSpace,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _SectionHeading(
              title: 'Search results',
              subtitle:
                  '${sortedEvents.length} event${sortedEvents.length == 1 ? '' : 's'} found',
            );
          }
          final EventModel event = sortedEvents[index - 1];
          return _SearchEventCard(
            event: event,
            onTap: () => onTapEvent(event),
          );
        },
      ),
    );
  }
}

class _SectionHeading extends StatelessWidget {
  const _SectionHeading({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CommonText(
          text: title,
          color: AppColors.textPrimary,
          fontSize: 20.sp,
          fontWeight: FontWeight.w700,
        ),
        3.h.verticalSpace,
        CommonText(
          text: subtitle,
          color: AppColors.textSecondary,
          fontSize: 12.sp,
          fontWeight: FontWeight.w400,
        ),
      ],
    );
  }
}

class _FeaturedEventCard extends StatelessWidget {
  const _FeaturedEventCard({required this.event, required this.onTap});

  final EventModel event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String location = _eventPlace(event);
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(18.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EventImage(
                imageUrl: event.image,
                height: 174.h,
                width: double.infinity,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(17.r),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(15.w, 13.h, 15.w, 15.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CommonText(
                            text: _eventTitle(event),
                            color: AppColors.textPrimary,
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            maxLine: 2,
                            softWrap: true,
                          ),
                          7.h.verticalSpace,
                          CommonText(
                            text: _eventTime(event),
                            color: AppColors.primary,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                          if (location.isNotEmpty) ...[
                            5.h.verticalSpace,
                            CommonText(
                              text: location,
                              color: AppColors.textSecondary,
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                              maxLine: 1,
                            ),
                          ],
                        ],
                      ),
                    ),
                    10.w.horizontalSpace,
                    Container(
                      height: 36.w,
                      width: 36.w,
                      decoration: const BoxDecoration(
                        color: AppColors.surfaceElevated,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        color: AppColors.primary,
                        size: 18.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SoonEventCard extends StatelessWidget {
  const _SoonEventCard({required this.event, required this.onTap});

  final EventModel event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String location = _eventPlace(event);
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(15.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          width: 154.w,
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EventImage(
                imageUrl: event.image,
                height: 88.h,
                width: double.infinity,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(14.r),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(10.w, 9.h, 10.w, 9.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommonText(
                        text: _eventTitle(event),
                        color: AppColors.textPrimary,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        maxLine: 2,
                        softWrap: true,
                      ),
                      const Spacer(),
                      CommonText(
                        text: _eventShortDate(event),
                        color: AppColors.primary,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        maxLine: 1,
                      ),
                      if (location.isNotEmpty) ...[
                        3.h.verticalSpace,
                        CommonText(
                          text: location,
                          color: AppColors.textSecondary,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          maxLine: 1,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchEventCard extends StatelessWidget {
  const _SearchEventCard({required this.event, required this.onTap});

  final EventModel event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String location = _eventPlace(event);
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(15.r),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: Row(
            children: [
              EventImage(
                imageUrl: event.image,
                height: 76.w,
                width: 76.w,
                borderRadius: BorderRadius.circular(11.r),
              ),
              12.w.horizontalSpace,
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CommonText(
                      text: _eventTitle(event),
                      color: AppColors.textPrimary,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      maxLine: 2,
                      softWrap: true,
                    ),
                    6.h.verticalSpace,
                    CommonText(
                      text: _eventTime(event),
                      color: AppColors.primary,
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      maxLine: 1,
                    ),
                    if (location.isNotEmpty) ...[
                      4.h.verticalSpace,
                      CommonText(
                        text: location,
                        color: AppColors.textSecondary,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        maxLine: 1,
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textSecondary,
                size: 21.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InterestChip extends StatelessWidget {
  const _InterestChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(99.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(99.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 8.h),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.border),
            borderRadius: BorderRadius.circular(99.r),
          ),
          child: CommonText(
            text: label,
            color: AppColors.textPrimary,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _EmptyHome extends StatelessWidget {
  const _EmptyHome({required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 180),
          _EmptyMessage(
            icon: Icons.auto_awesome_outlined,
            title: 'Fresh ideas are on the way',
            message: 'Check back soon for upcoming Free2B events.',
          ),
        ],
      ),
    );
  }
}

class _EmptySearch extends StatelessWidget {
  const _EmptySearch({required this.onRefresh});

  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 150),
          _EmptyMessage(
            icon: Icons.search_off_rounded,
            title: 'No events found',
            message: 'Try another event name, ZIP code, or interest.',
          ),
        ],
      ),
    );
  }
}

class _EmptyMessage extends StatelessWidget {
  const _EmptyMessage({
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          Icon(icon, color: AppColors.primary, size: 36),
          const SizedBox(height: 14),
          CommonText(
            text: title,
            color: AppColors.textPrimary,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 7),
          CommonText(
            text: message,
            color: AppColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w400,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

List<EventModel> _sortUpcoming(List<EventModel> events) {
  final List<EventModel> sorted = events.toList();
  sorted.sort((a, b) {
    final DateTime? aDate = EventDateUtils.parseEventDateTime(a.startDate);
    final DateTime? bDate = EventDateUtils.parseEventDateTime(b.startDate);
    if (aDate == null && bDate == null) {
      return _eventTitle(a).compareTo(_eventTitle(b));
    }
    if (aDate == null) return 1;
    if (bDate == null) return -1;
    return aDate.compareTo(bDate);
  });
  return sorted;
}

EventModel? _featuredEvent(List<EventModel> events) {
  if (events.isEmpty) return null;
  final DateTime now = DateTime.now();
  final DateTime weekEnd = now.add(const Duration(days: 7));
  for (final EventModel event in events) {
    final DateTime? date = EventDateUtils.parseEventDateTime(event.startDate);
    if (date != null && !date.isBefore(now) && !date.isAfter(weekEnd)) {
      return event;
    }
  }
  return events.first;
}

List<String> _categoriesFrom(List<EventModel> events) {
  final Set<String> categories = <String>{};
  for (final EventModel event in events) {
    for (final category in event.category ?? <Category>[]) {
      final String name = (category.categoryName ?? '').trim();
      if (name.isNotEmpty) categories.add(name);
    }
  }
  final List<String> sorted = categories.toList()..sort();
  return sorted.take(8).toList();
}

bool _sameEvent(EventModel event, EventModel? other) {
  if (other == null) return false;
  if (identical(event, other)) return true;
  final String eventId = (event.eventID ?? '').trim();
  return eventId.isNotEmpty && eventId == other.eventID;
}

String _eventTitle(EventModel event) {
  final String title = (event.title ?? '').trim();
  return title.isEmpty ? 'Free2B event' : title;
}

String _eventTime(EventModel event) {
  final DateTime? date = EventDateUtils.parseEventDateTime(event.startDate);
  if (date == null) return 'Date and time coming soon';
  return DateFormat('EEE, MMM d • h:mm a').format(date);
}

String _eventShortDate(EventModel event) {
  final DateTime? date = EventDateUtils.parseEventDateTime(event.startDate);
  if (date == null) return 'Date coming soon';
  return DateFormat('MMM d • h:mm a').format(date);
}

String _eventPlace(EventModel event) {
  final String venue = (event.venue ?? '').trim();
  if (venue.isNotEmpty) return venue;
  return <String?>[event.city, event.state]
      .whereType<String>()
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .join(', ');
}

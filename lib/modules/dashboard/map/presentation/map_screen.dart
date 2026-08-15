import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/modules/dashboard/home/controller/home_controller.dart';
import 'package:flutter_template/modules/dashboard/home/model/event_model.dart';
import 'package:flutter_template/modules/dashboard/map/data/map_event_location_service.dart';
import 'package:flutter_template/utils/app_colors.dart';
import 'package:flutter_template/utils/event_date_utils.dart';
import 'package:flutter_template/utils/location_service.dart';
import 'package:flutter_template/utils/navigation_utils/navigation.dart';
import 'package:flutter_template/utils/navigation_utils/routes.dart';
import 'package:flutter_template/widget/common_text.dart';
import 'package:flutter_template/widget/event_image.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart' show DateFormat;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const LatLng _defaultCenter = LatLng(41.8781, -87.6298);
  static const CameraPosition _defaultCamera = CameraPosition(
    target: _defaultCenter,
    zoom: 11.6,
  );
  static const ClusterManagerId _eventClusterId =
      ClusterManagerId('free2b_events');

  late final HomeController _homeController;
  late final ClusterManager _eventClusterManager;
  final MapEventLocationService _locationService = MapEventLocationService();
  final TextEditingController _zipController = TextEditingController();
  final FocusNode _zipFocusNode = FocusNode();

  GoogleMapController? _mapController;
  Worker? _eventWorker;
  Timer? _zipDebounce;
  bool _isNight = true;
  bool _isTrayExpanded = false;
  bool _isResolvingLocations = false;
  bool _isZipLoading = false;
  bool _isLocating = false;
  String _zipFilter = '';
  String? _mapMessage;
  String? _locationMessage;
  Position? _userPosition;
  EventModel? _selectedEvent;
  List<MapEventLocation> _resolvedEvents = <MapEventLocation>[];
  Set<Marker> _markers = <Marker>{};

  @override
  void initState() {
    super.initState();
    _homeController = Get.isRegistered<HomeController>()
        ? Get.find<HomeController>()
        : Get.put(HomeController());
    _eventClusterManager = ClusterManager(
      clusterManagerId: _eventClusterId,
      onClusterTap: _onClusterTap,
    );
    _resolveVisibleEventLocations();
    _eventWorker = ever<List<EventModel>>(_homeController.eventData, (_) {
      _resolveVisibleEventLocations();
    });
  }

  @override
  void dispose() {
    _zipDebounce?.cancel();
    _eventWorker?.dispose();
    _zipController.dispose();
    _zipFocusNode.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<MapEventLocation> visibleEvents = _visibleEventLocations();

    return Scaffold(
      backgroundColor: _isNight ? const Color(0xFF060812) : const Color(0xFFF3F6FA),
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Positioned.fill(
              child: GoogleMap(
                initialCameraPosition: _defaultCamera,
                mapType: MapType.normal,
                markers: _markers,
                clusterManagers: {_eventClusterManager},
                myLocationEnabled: _userPosition != null,
                myLocationButtonEnabled: false,
                zoomControlsEnabled: false,
                compassEnabled: true,
                mapToolbarEnabled: false,
                onMapCreated: _onMapCreated,
                onTap: (_) => _clearSelectedEvent(),
              ),
            ),
            Positioned(
              top: 10.h,
              left: 14.w,
              right: 14.w,
              child: _MapHeader(
                isNight: _isNight,
                zipController: _zipController,
                zipFocusNode: _zipFocusNode,
                isZipLoading: _isZipLoading,
                onModeChanged: _changeMapMode,
                onZipChanged: _onZipChanged,
                onZipSubmitted: _applyZipSearch,
                onSearchTap: () => _zipFocusNode.requestFocus(),
                onFilterTap: () => setState(() => _isTrayExpanded = true),
                onClearZip: _zipFilter.isEmpty && _zipController.text.isEmpty
                    ? null
                    : _clearZipSearch,
              ),
            ),
            Positioned(
              top: 126.h,
              right: 14.w,
              child: Column(
                children: [
                  _MapFloatingButton(
                    icon: Icons.my_location_rounded,
                    tooltip: 'Recenter',
                    isNight: _isNight,
                    isLoading: _isLocating,
                    onTap: _recenterToUser,
                  ),
                  10.h.verticalSpace,
                  _MapFloatingButton(
                    icon: Icons.layers_rounded,
                    tooltip: _isNight ? 'Day map' : 'Night map',
                    isNight: _isNight,
                    onTap: () => _changeMapMode(!_isNight),
                  ),
                ],
              ),
            ),
            if (_isResolvingLocations || _homeController.isEventLoading.value)
              Positioned(
                top: 128.h,
                left: 14.w,
                child: _MapStatusPill(
                  text: 'Loading map events',
                  isNight: _isNight,
                  showSpinner: true,
                ),
              ),
            if (_mapMessage != null || _locationMessage != null)
              Positioned(
                top: 128.h,
                left: 14.w,
                right: 72.w,
                child: _MapMessageCard(
                  message: _locationMessage ?? _mapMessage!,
                  isNight: _isNight,
                  onClose: () => setState(() {
                    _mapMessage = null;
                    _locationMessage = null;
                  }),
                ),
              ),
            if (_selectedEvent != null)
              Positioned(
                left: 14.w,
                right: 14.w,
                bottom: _isTrayExpanded ? 248.h : 104.h,
                child: _SelectedEventCard(
                  event: _selectedEvent!,
                  isNight: _isNight,
                  onTap: () => _openEvent(_selectedEvent!),
                  onClose: _clearSelectedEvent,
                ),
              ),
            if (visibleEvents.isEmpty &&
                !_isResolvingLocations &&
                !_homeController.isEventLoading.value)
              Center(
                child: _EmptyMapState(
                  isNight: _isNight,
                  zipFilter: _zipFilter,
                ),
              ),
            Positioned.fill(
              child: IgnorePointer(
                ignoring: !_isTrayExpanded,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: _isTrayExpanded ? 1 : 0,
                  child: Container(color: Colors.black.withOpacity(0.20)),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 8.h,
              child: _EventTray(
                events: visibleEvents.map((item) => item.event).toList(),
                zipFilter: _zipFilter,
                isExpanded: _isTrayExpanded,
                onToggleExpanded: () {
                  setState(() => _isTrayExpanded = !_isTrayExpanded);
                },
                onTapEvent: _openEvent,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _onMapCreated(GoogleMapController controller) async {
    _mapController = controller;
    await _applyMapStyle();
    await _fitMapToVisibleEvents();
  }

  Future<void> _changeMapMode(bool isNight) async {
    setState(() => _isNight = isNight);
    await _applyMapStyle();
  }

  Future<void> _applyMapStyle() async {
    final GoogleMapController? controller = _mapController;
    if (controller == null) {
      return;
    }
    await controller.setMapStyle(_isNight ? _nightMapStyle : _dayMapStyle);
  }

  Future<void> _resolveVisibleEventLocations() async {
    setState(() {
      _isResolvingLocations = true;
      _mapMessage = null;
    });

    final List<EventModel> events = _homeController.eventData.toList();
    final List<MapEventLocation> resolved =
        await _locationService.resolveEventLocations(events);

    if (!mounted) {
      return;
    }

    setState(() {
      _resolvedEvents = resolved;
      _isResolvingLocations = false;
      _markers = _buildMarkers(_visibleEventLocations());
      if (events.isNotEmpty && resolved.isEmpty) {
        _mapMessage =
            'Events loaded, but none have usable coordinates or geocodable locations yet.';
      }
    });
    await _fitMapToVisibleEvents();
  }

  List<MapEventLocation> _visibleEventLocations() {
    final String filter = _locationService.normalizeZip(_zipFilter);
    final List<MapEventLocation> events = filter.isEmpty
        ? _resolvedEvents
        : _resolvedEvents.where((item) {
            final String eventZip =
                _locationService.normalizeZip(item.event.zipCode);
            return eventZip == filter ||
                (eventZip.length >= 3 &&
                    filter.length >= 3 &&
                    eventZip.substring(0, 3) == filter.substring(0, 3));
          }).toList();

    events.sort((a, b) {
      final DateTime? aDate =
          EventDateUtils.parseEventDateTime(a.event.startDate);
      final DateTime? bDate =
          EventDateUtils.parseEventDateTime(b.event.startDate);
      if (aDate == null && bDate == null) {
        return _eventTitle(a.event).compareTo(_eventTitle(b.event));
      }
      if (aDate == null) return 1;
      if (bDate == null) return -1;
      return aDate.compareTo(bDate);
    });

    return events;
  }

  Set<Marker> _buildMarkers(List<MapEventLocation> locations) {
    return locations.map((MapEventLocation item) {
      final bool selected = _selectedEvent?.eventID == item.event.eventID &&
          (item.event.eventID ?? '').isNotEmpty;
      return Marker(
        markerId: MarkerId(_markerIdFor(item.event)),
        position: item.position,
        clusterManagerId: _eventClusterId,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          selected ? BitmapDescriptor.hueRose : BitmapDescriptor.hueViolet,
        ),
        infoWindow: InfoWindow.noText,
        onTap: () => _selectEvent(item),
      );
    }).toSet();
  }

  Future<void> _selectEvent(MapEventLocation item) async {
    setState(() {
      _selectedEvent = item.event;
      _markers = _buildMarkers(_visibleEventLocations());
    });
    await _mapController?.animateCamera(
      CameraUpdate.newLatLng(item.position),
    );
  }

  void _clearSelectedEvent() {
    setState(() {
      _selectedEvent = null;
      _markers = _buildMarkers(_visibleEventLocations());
    });
  }

  Future<void> _onClusterTap(Cluster cluster) async {
    await _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(cluster.bounds, 72.w),
    );
  }

  void _onZipChanged(String value) {
    _zipDebounce?.cancel();
    final String normalized = _locationService.normalizeZip(value);
    setState(() {
      _zipFilter = normalized;
      _selectedEvent = null;
      _mapMessage = null;
      _markers = _buildMarkers(_visibleEventLocations());
    });

    if (normalized.length == 5) {
      _zipDebounce = Timer(const Duration(milliseconds: 450), () {
        _applyZipSearch(normalized);
      });
    } else if (normalized.isNotEmpty) {
      setState(() {
        _mapMessage = 'Enter a 5-digit US ZIP code.';
      });
    }
  }

  Future<void> _applyZipSearch(String value) async {
    final String zipCode = _locationService.normalizeZip(value);
    setState(() {
      _zipFilter = zipCode;
      _isZipLoading = true;
      _selectedEvent = null;
      _mapMessage = null;
      _markers = _buildMarkers(_visibleEventLocations());
    });

    final ZipLookupResult result =
        await _locationService.resolveZipCode(zipCode);

    if (!mounted) {
      return;
    }

    setState(() {
      _isZipLoading = false;
      switch (result.status) {
        case ZipLookupStatus.empty:
          _mapMessage = null;
          break;
        case ZipLookupStatus.invalid:
        case ZipLookupStatus.notFound:
        case ZipLookupStatus.error:
          _mapMessage = result.message;
          break;
        case ZipLookupStatus.found:
          _mapMessage = null;
          break;
      }
    });

    if (result.position != null) {
      await _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: result.position!, zoom: 12.4),
        ),
      );
    }
  }

  Future<void> _clearZipSearch() async {
    _zipDebounce?.cancel();
    _zipController.clear();
    setState(() {
      _zipFilter = '';
      _selectedEvent = null;
      _mapMessage = null;
      _markers = _buildMarkers(_visibleEventLocations());
    });
    await _fitMapToVisibleEvents();
  }

  Future<void> _recenterToUser() async {
    setState(() {
      _isLocating = true;
      _locationMessage = null;
    });

    final AppLocationLookupResult result =
        await AppLocationService.getCurrentLocationIfAllowed();
    if (!mounted) {
      return;
    }

    if (!result.hasCoordinates) {
      setState(() {
        _isLocating = false;
        _userPosition = null;
        _locationMessage = _locationStatusMessage(result);
      });
      return;
    }

    setState(() {
      _isLocating = false;
      _userPosition = result.position;
      _locationMessage = null;
    });

    await _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(
            result.position!.latitude,
            result.position!.longitude,
          ),
          zoom: 13.5,
        ),
      ),
    );
  }

  Future<void> _fitMapToVisibleEvents() async {
    final GoogleMapController? controller = _mapController;
    if (controller == null) {
      return;
    }

    final List<MapEventLocation> events = _visibleEventLocations();
    if (events.isEmpty) {
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(_defaultCamera),
      );
      return;
    }

    if (events.length == 1) {
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: events.first.position, zoom: 13.2),
        ),
      );
      return;
    }

    double minLat = events.first.position.latitude;
    double maxLat = events.first.position.latitude;
    double minLng = events.first.position.longitude;
    double maxLng = events.first.position.longitude;

    for (final MapEventLocation event in events) {
      minLat = math.min(minLat, event.position.latitude);
      maxLat = math.max(maxLat, event.position.latitude);
      minLng = math.min(minLng, event.position.longitude);
      maxLng = math.max(maxLng, event.position.longitude);
    }

    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        70.w,
      ),
    );
  }

  String _markerIdFor(EventModel event) {
    final String id = (event.eventID ?? '').trim();
    if (id.isNotEmpty) {
      return id;
    }
    return '${event.title ?? 'event'}-${event.startDate ?? ''}-${event.zipCode ?? ''}';
  }

  String _locationStatusMessage(AppLocationLookupResult result) {
    switch (result.status) {
      case 'service_disabled':
        return 'Location services are disabled. Turn them on to recenter the map.';
      case 'denied':
        return 'Location permission was denied. Enable it to show your position.';
      case 'deniedForever':
        return 'Location permission is permanently denied. Update it in system settings.';
      default:
        return result.message ?? 'Current location is unavailable.';
    }
  }

  void _openEvent(EventModel event) {
    Navigation.pushNamed(Routes.detailsScreen, arg: event);
  }
}

class _MapHeader extends StatelessWidget {
  const _MapHeader({
    required this.isNight,
    required this.zipController,
    required this.zipFocusNode,
    required this.isZipLoading,
    required this.onModeChanged,
    required this.onZipChanged,
    required this.onZipSubmitted,
    required this.onSearchTap,
    required this.onFilterTap,
    required this.onClearZip,
  });

  final bool isNight;
  final TextEditingController zipController;
  final FocusNode zipFocusNode;
  final bool isZipLoading;
  final ValueChanged<bool> onModeChanged;
  final ValueChanged<String> onZipChanged;
  final ValueChanged<String> onZipSubmitted;
  final VoidCallback onSearchTap;
  final VoidCallback onFilterTap;
  final VoidCallback? onClearZip;

  @override
  Widget build(BuildContext context) {
    final Color surface =
        isNight ? const Color(0xE80B0F18) : Colors.white.withOpacity(0.95);
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
              onTap: onSearchTap,
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
              onTap: onFilterTap,
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
                  ? Colors.white.withOpacity(0.12)
                  : const Color(0xFFE1E6EF),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isNight ? 0.28 : 0.10),
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
                    focusNode: zipFocusNode,
                    keyboardType: TextInputType.number,
                    maxLength: 5,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    onChanged: onZipChanged,
                    onSubmitted: onZipSubmitted,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      hintText: 'US ZIP',
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
                      suffixIcon: isZipLoading
                          ? Padding(
                              padding: EdgeInsets.all(11.w),
                              child: CircularProgressIndicator(
                                color: const Color(0xFFFF58F3),
                                strokeWidth: 2,
                              ),
                            )
                          : onClearZip == null
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
                          ? Colors.black.withOpacity(0.30)
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
                    color: const Color(0xFFFF58F3).withOpacity(0.28),
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
  const _RoundIconButton({
    required this.icon,
    required this.isNight,
    this.onTap,
  });

  final IconData icon;
  final bool isNight;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40.w,
        width: 40.w,
        decoration: BoxDecoration(
          color: isNight ? Colors.black.withOpacity(0.42) : Colors.white,
          shape: BoxShape.circle,
          border: Border.all(
            color: isNight ? Colors.white.withOpacity(0.10) : const Color(0xFFE1E6EF),
          ),
        ),
        child: Icon(
          icon,
          color: isNight ? AppColors.textColor : const Color(0xFF172033),
          size: 23.sp,
        ),
      ),
    );
  }
}

class _MapFloatingButton extends StatelessWidget {
  const _MapFloatingButton({
    required this.icon,
    required this.tooltip,
    required this.isNight,
    required this.onTap,
    this.isLoading = false,
  });

  final IconData icon;
  final String tooltip;
  final bool isNight;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: isLoading ? null : onTap,
        child: Container(
          height: 44.w,
          width: 44.w,
          decoration: BoxDecoration(
            color: isNight ? const Color(0xE80B0F18) : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: isNight
                  ? Colors.white.withOpacity(0.14)
                  : const Color(0xFFE1E6EF),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isNight ? 0.36 : 0.12),
                blurRadius: 18.r,
                offset: Offset(0, 8.h),
              ),
            ],
          ),
          child: isLoading
              ? Padding(
                  padding: EdgeInsets.all(12.w),
                  child: CircularProgressIndicator(
                    color: const Color(0xFF2D9BFF),
                    strokeWidth: 2,
                  ),
                )
              : Icon(
                  icon,
                  color: isNight ? AppColors.textColor : const Color(0xFF172033),
                  size: 22.sp,
                ),
        ),
      ),
    );
  }
}

class _MapStatusPill extends StatelessWidget {
  const _MapStatusPill({
    required this.text,
    required this.isNight,
    this.showSpinner = false,
  });

  final String text;
  final bool isNight;
  final bool showSpinner;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: isNight ? const Color(0xE80B0F18) : Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: Colors.white.withOpacity(isNight ? 0.12 : 0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showSpinner) ...[
            SizedBox(
              height: 14.w,
              width: 14.w,
              child: CircularProgressIndicator(
                color: const Color(0xFFFF58F3),
                strokeWidth: 2,
              ),
            ),
            8.w.horizontalSpace,
          ],
          CommonText(
            text: text,
            color: isNight ? AppColors.textColor : const Color(0xFF172033),
            fontSize: 12.sp,
            fontWeight: FontWeight.w800,
          ),
        ],
      ),
    );
  }
}

class _MapMessageCard extends StatelessWidget {
  const _MapMessageCard({
    required this.message,
    required this.isNight,
    required this.onClose,
  });

  final String message;
  final bool isNight;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(12.w, 10.h, 8.w, 10.h),
      decoration: BoxDecoration(
        color: isNight ? const Color(0xF20B0F18) : Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isNight ? Colors.white.withOpacity(0.14) : const Color(0xFFE1E6EF),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: CommonText(
              text: message,
              color: isNight ? AppColors.textColor : const Color(0xFF172033),
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              maxLine: 3,
              softWrap: true,
            ),
          ),
          GestureDetector(
            onTap: onClose,
            child: Icon(
              Icons.close_rounded,
              color: isNight ? AppColors.textLightColor : const Color(0xFF637083),
              size: 20.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedEventCard extends StatelessWidget {
  const _SelectedEventCard({
    required this.event,
    required this.isNight,
    required this.onTap,
    required this.onClose,
  });

  final EventModel event;
  final bool isNight;
  final VoidCallback onTap;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final String location = _eventLocation(event);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(10.w),
        decoration: BoxDecoration(
          color: isNight ? const Color(0xF20B0F18) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: const Color(0xFFFF58F3).withOpacity(isNight ? 0.72 : 0.34),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF58F3).withOpacity(isNight ? 0.26 : 0.12),
              blurRadius: 22.r,
              offset: Offset(0, 10.h),
            ),
          ],
        ),
        child: Row(
          children: [
            EventImage(
              imageUrl: event.image,
              height: 72.w,
              width: 72.w,
              borderRadius: BorderRadius.circular(12.r),
            ),
            11.w.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  CommonText(
                    text: _eventTitle(event),
                    color: isNight ? AppColors.textColor : const Color(0xFF172033),
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w800,
                    maxLine: 2,
                    softWrap: true,
                  ),
                  6.h.verticalSpace,
                  CommonText(
                    text: _eventTime(event),
                    color: isNight ? AppColors.textLightColor : const Color(0xFF637083),
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    maxLine: 1,
                    softWrap: false,
                  ),
                  if (location.isNotEmpty) ...[
                    5.h.verticalSpace,
                    CommonText(
                      text: location,
                      color: const Color(0xFF2D9BFF),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
                      maxLine: 1,
                      softWrap: false,
                    ),
                  ],
                ],
              ),
            ),
            8.w.horizontalSpace,
            GestureDetector(
              onTap: onClose,
              child: Icon(
                Icons.close_rounded,
                color: isNight ? AppColors.textLightColor : const Color(0xFF637083),
                size: 22.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventTray extends StatelessWidget {
  const _EventTray({
    required this.events,
    required this.zipFilter,
    required this.isExpanded,
    required this.onToggleExpanded,
    required this.onTapEvent,
  });

  final List<EventModel> events;
  final String zipFilter;
  final bool isExpanded;
  final VoidCallback onToggleExpanded;
  final ValueChanged<EventModel> onTapEvent;

  @override
  Widget build(BuildContext context) {
    final double height = isExpanded ? 324.h : 84.h;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      height: height,
      margin: EdgeInsets.symmetric(horizontal: 14.w),
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
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onToggleExpanded,
            child: Column(
              children: [
                Center(
                  child: Container(
                    height: 4.h,
                    width: 42.w,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.20),
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
                                ? 'Map events'
                                : 'Events near $zipFilter',
                            color: AppColors.textColor,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            maxLine: 1,
                            softWrap: false,
                          ),
                          2.h.verticalSpace,
                          CommonText(
                            text:
                                '${events.length} event${events.length == 1 ? '' : 's'} represented',
                            color: AppColors.textLightColor,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            maxLine: 1,
                            softWrap: false,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      height: 32.w,
                      width: 32.w,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.07),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_down_rounded
                            : Icons.keyboard_arrow_up_rounded,
                        color: AppColors.textLightColor,
                        size: 24.sp,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (isExpanded) ...[
            12.h.verticalSpace,
            Expanded(
              child: events.isEmpty
                  ? Center(
                      child: CommonText(
                        text: 'Try another ZIP code or clear the search.',
                        color: AppColors.textLightColor,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w700,
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.separated(
                      padding: EdgeInsets.zero,
                      itemCount: events.length,
                      separatorBuilder: (_, __) => 10.h.verticalSpace,
                      itemBuilder: (context, index) {
                        final EventModel event = events[index];
                        return _TrayEventCard(
                          event: event,
                          onTap: () => onTapEvent(event),
                        );
                      },
                    ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TrayEventCard extends StatelessWidget {
  const _TrayEventCard({
    required this.event,
    required this.onTap,
  });

  final EventModel event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final String location = _eventLocation(event);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.w),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(
          children: [
            EventImage(
              imageUrl: event.image,
              height: 52.w,
              width: 52.w,
              borderRadius: BorderRadius.circular(9.r),
            ),
            10.w.horizontalSpace,
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CommonText(
                    text: _eventTitle(event),
                    color: AppColors.textColor,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    maxLine: 2,
                    softWrap: true,
                  ),
                  5.h.verticalSpace,
                  CommonText(
                    text: _eventTime(event),
                    color: AppColors.textLightColor,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    maxLine: 1,
                    softWrap: false,
                  ),
                  if (location.isNotEmpty) ...[
                    4.h.verticalSpace,
                    CommonText(
                      text: location,
                      color: const Color(0xFF2D9BFF),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w800,
                      maxLine: 1,
                      softWrap: false,
                    ),
                  ],
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: AppColors.textLightColor,
              size: 22.sp,
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
    return Container(
      width: 250.w,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: isNight ? const Color(0xE80A0D14) : Colors.white.withOpacity(0.96),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isNight ? Colors.white.withOpacity(0.12) : const Color(0xFFE1E6EF),
        ),
      ),
      child: CommonText(
        text: zipFilter.isEmpty
            ? 'No mapped events are available yet.'
            : 'No mapped events matched that ZIP code.',
        color: isNight ? AppColors.textColor : const Color(0xFF172033),
        fontSize: 13.sp,
        fontWeight: FontWeight.w700,
        textAlign: TextAlign.center,
      ),
    );
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

String _eventLocation(EventModel event) {
  final List<String> parts = <String?>[
    event.address,
    event.city,
    event.state,
    event.zipCode,
  ]
      .whereType<String>()
      .map((String value) => value.trim())
      .where((String value) => value.isNotEmpty)
      .toList();
  return parts.join(', ');
}

const String _dayMapStyle = '''
[
  {
    "featureType": "poi.business",
    "stylers": [{ "visibility": "off" }]
  },
  {
    "featureType": "poi",
    "elementType": "labels.icon",
    "stylers": [{ "visibility": "off" }]
  },
  {
    "featureType": "water",
    "stylers": [{ "color": "#bfe7ff" }]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [{ "color": "#ffffff" }]
  },
  {
    "featureType": "road.arterial",
    "elementType": "geometry",
    "stylers": [{ "color": "#e7edf5" }]
  }
]
''';

const String _nightMapStyle = '''
[
  {
    "elementType": "geometry",
    "stylers": [{ "color": "#070a13" }]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [{ "color": "#d8d9ff" }]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [{ "color": "#080914" }]
  },
  {
    "featureType": "administrative.locality",
    "elementType": "labels.text.fill",
    "stylers": [{ "color": "#ff8df7" }]
  },
  {
    "featureType": "landscape",
    "elementType": "geometry",
    "stylers": [{ "color": "#080b15" }]
  },
  {
    "featureType": "poi",
    "elementType": "labels.icon",
    "stylers": [{ "visibility": "off" }]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry",
    "stylers": [{ "color": "#071a18" }]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [{ "color": "#303342" }]
  },
  {
    "featureType": "road",
    "elementType": "geometry.stroke",
    "stylers": [{ "color": "#141626" }]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [{ "color": "#aeb3c7" }]
  },
  {
    "featureType": "road.arterial",
    "elementType": "geometry",
    "stylers": [{ "color": "#4b315e" }]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [{ "color": "#5b23e5" }]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [{ "color": "#ff58f3" }]
  },
  {
    "featureType": "transit",
    "elementType": "geometry",
    "stylers": [{ "color": "#1f2540" }]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [{ "color": "#06345d" }]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [{ "color": "#2d9bff" }]
  }
]
''';

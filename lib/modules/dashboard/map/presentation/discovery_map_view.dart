import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_template/modules/dashboard/home/model/event_model.dart';
import 'package:flutter_template/modules/dashboard/map/data/map_event_location_service.dart';
import 'package:flutter_template/utils/app_colors.dart';
import 'package:flutter_template/utils/event_date_utils.dart';
import 'package:flutter_template/widget/common_text.dart';
import 'package:flutter_template/widget/event_image.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

const bool discoveryMapEnabled = bool.fromEnvironment(
  'FREE2B_ENABLE_DISCOVERY_MAP',
  defaultValue: false,
);

enum DiscoveryViewMode { list, map }

class DiscoveryMapView extends StatefulWidget {
  const DiscoveryMapView({
    super.key,
    required this.events,
    required this.recenterTarget,
    required this.isLoading,
    required this.onEventTap,
    required this.onDirections,
  });

  final List<MapEventLocation> events;
  final LatLng? recenterTarget;
  final bool isLoading;
  final ValueChanged<EventModel> onEventTap;
  final void Function(EventModel event, LatLng position) onDirections;

  @override
  State<DiscoveryMapView> createState() => _DiscoveryMapViewState();
}

class _DiscoveryMapViewState extends State<DiscoveryMapView> {
  static const CameraPosition _chicagoCamera = CameraPosition(
    target: LatLng(41.8781, -87.6298),
    zoom: 11.4,
  );
  static const ClusterManagerId _clusterId =
      ClusterManagerId('free2b_discovery_events');

  late final ClusterManager _clusterManager;
  GoogleMapController? _mapController;
  EventModel? _selectedEvent;
  Set<Marker> _markers = <Marker>{};

  @override
  void initState() {
    super.initState();
    _clusterManager = ClusterManager(
      clusterManagerId: _clusterId,
      onClusterTap: _onClusterTap,
    );
    _markers = _buildMarkers();
  }

  @override
  void didUpdateWidget(covariant DiscoveryMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final bool selectedEventStillVisible = _selectedEvent == null ||
        widget.events.any(
          (item) => _eventKey(item.event) == _eventKey(_selectedEvent!),
        );
    if (!selectedEventStillVisible) {
      _selectedEvent = null;
    }
    _markers = _buildMarkers();

    if (oldWidget.recenterTarget != widget.recenterTarget ||
        oldWidget.events.length != widget.events.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _moveCamera());
    }
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: GoogleMap(
            key: const ValueKey<String>('discovery-google-map'),
            initialCameraPosition: _chicagoCamera,
            mapType: MapType.normal,
            markers: _markers,
            clusterManagers: <ClusterManager>{_clusterManager},
            compassEnabled: true,
            mapToolbarEnabled: false,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
              _moveCamera();
            },
            onTap: (_) => _clearSelection(),
          ),
        ),
        if (widget.isLoading)
          Positioned(
            top: 12.h,
            left: 16.w,
            child: const _MapStatusPill(),
          ),
        if (widget.events.isEmpty && !widget.isLoading)
          const Center(child: _EmptyMapMessage()),
        if (_selectedEvent != null)
          Positioned(
            left: 14.w,
            right: 14.w,
            bottom: 16.h,
            child: _SelectedEventPreview(
              event: _selectedEvent!,
              onOpen: () => widget.onEventTap(_selectedEvent!),
              onDirections: () {
                final MapEventLocation? location = _locationFor(_selectedEvent!);
                if (location != null) {
                  widget.onDirections(location.event, location.position);
                }
              },
              onClose: _clearSelection,
            ),
          ),
      ],
    );
  }

  Set<Marker> _buildMarkers() {
    final String? selectedKey =
        _selectedEvent == null ? null : _eventKey(_selectedEvent!);
    return widget.events.map((MapEventLocation item) {
      final bool selected = _eventKey(item.event) == selectedKey;
      return Marker(
        markerId: MarkerId(_eventKey(item.event)),
        position: item.position,
        clusterManagerId: _clusterId,
        icon: BitmapDescriptor.defaultMarkerWithHue(
          selected ? BitmapDescriptor.hueYellow : BitmapDescriptor.hueViolet,
        ),
        infoWindow: InfoWindow.noText,
        onTap: () => _selectEvent(item),
      );
    }).toSet();
  }

  Future<void> _selectEvent(MapEventLocation item) async {
    setState(() {
      _selectedEvent = item.event;
      _markers = _buildMarkers();
    });
    await _mapController?.animateCamera(CameraUpdate.newLatLng(item.position));
  }

  void _clearSelection() {
    if (_selectedEvent == null) return;
    setState(() {
      _selectedEvent = null;
      _markers = _buildMarkers();
    });
  }

  Future<void> _onClusterTap(Cluster cluster) async {
    await _mapController?.animateCamera(
      CameraUpdate.newLatLngBounds(cluster.bounds, 64.w),
    );
  }

  Future<void> _moveCamera() async {
    final GoogleMapController? controller = _mapController;
    if (controller == null) return;

    final LatLng? target = widget.recenterTarget;
    if (target != null) {
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: target, zoom: 13.2),
        ),
      );
      return;
    }

    if (widget.events.isEmpty) {
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(_chicagoCamera),
      );
      return;
    }
    if (widget.events.length == 1) {
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: widget.events.single.position, zoom: 14),
        ),
      );
      return;
    }

    double minLatitude = widget.events.first.position.latitude;
    double maxLatitude = minLatitude;
    double minLongitude = widget.events.first.position.longitude;
    double maxLongitude = minLongitude;
    for (final MapEventLocation item in widget.events.skip(1)) {
      minLatitude = item.position.latitude < minLatitude
          ? item.position.latitude
          : minLatitude;
      maxLatitude = item.position.latitude > maxLatitude
          ? item.position.latitude
          : maxLatitude;
      minLongitude = item.position.longitude < minLongitude
          ? item.position.longitude
          : minLongitude;
      maxLongitude = item.position.longitude > maxLongitude
          ? item.position.longitude
          : maxLongitude;
    }
    if (minLatitude == maxLatitude) {
      minLatitude -= 0.002;
      maxLatitude += 0.002;
    }
    if (minLongitude == maxLongitude) {
      minLongitude -= 0.002;
      maxLongitude += 0.002;
    }
    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLatitude, minLongitude),
          northeast: LatLng(maxLatitude, maxLongitude),
        ),
        52.w,
      ),
    );
  }

  MapEventLocation? _locationFor(EventModel event) {
    final String key = _eventKey(event);
    for (final MapEventLocation location in widget.events) {
      if (_eventKey(location.event) == key) return location;
    }
    return null;
  }
}

String discoveryEventKey(EventModel event) {
  final String eventId = (event.eventID ?? '').trim();
  if (eventId.isNotEmpty) return 'event:$eventId';
  final String source = (event.source ?? '').trim();
  final String sourceId = (event.sourceId ?? '').trim();
  if (source.isNotEmpty && sourceId.isNotEmpty) {
    return 'source:$source:$sourceId';
  }
  return 'identity:${identityHashCode(event)}';
}

String _eventKey(EventModel event) => discoveryEventKey(event);

class _SelectedEventPreview extends StatelessWidget {
  const _SelectedEventPreview({
    required this.event,
    required this.onOpen,
    required this.onDirections,
    required this.onClose,
  });

  final EventModel event;
  final VoidCallback onOpen;
  final VoidCallback onDirections;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final DateTime? date = EventDateUtils.parseEventDateTime(event.startDate);
    final String metadata = <String>[
      if (date != null) DateFormat('EEE, MMM d • h:mm a').format(date),
      if ((event.venue ?? '').trim().isNotEmpty) event.venue!.trim(),
    ].join('\n');

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: const ValueKey<String>('discovery-selected-event-preview'),
        onTap: onOpen,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.border),
            boxShadow: const <BoxShadow>[
              BoxShadow(color: Colors.black38, blurRadius: 18),
            ],
          ),
          child: Row(
            children: [
              EventImage(
                imageUrl: event.image,
                width: 72.w,
                height: 72.w,
                borderRadius: BorderRadius.circular(12.r),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CommonText(
                      text: (event.title ?? 'Free2B event').trim(),
                      color: AppColors.textPrimary,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      maxLine: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (metadata.isNotEmpty)
                      CommonText(
                        text: metadata,
                        color: AppColors.textSecondary,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        maxLine: 2,
                        overflow: TextOverflow.ellipsis,
                      ).paddingOnly(top: 5.h),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Directions',
                onPressed: onDirections,
                icon: Icon(Icons.directions_rounded, color: AppColors.primary),
              ),
              IconButton(
                tooltip: 'Close event preview',
                onPressed: onClose,
                icon: Icon(Icons.close_rounded, color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MapStatusPill extends StatelessWidget {
  const _MapStatusPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(18.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 14.w,
            height: 14.w,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 8.w),
          const Text('Locating events'),
        ],
      ),
    );
  }
}

class _EmptyMapMessage extends StatelessWidget {
  const _EmptyMapMessage();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: const Text('No events with usable locations in this view.'),
    );
  }
}

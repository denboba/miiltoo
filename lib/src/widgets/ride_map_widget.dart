import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/ride_model.dart';
import '../config/app_theme.dart';

class RideMapWidget extends StatefulWidget {
  final Ride ride;
  final double height;

  const RideMapWidget({
    super.key,
    required this.ride,
    this.height = 250,
  });

  @override
  State<RideMapWidget> createState() => _RideMapWidgetState();
}

class _RideMapWidgetState extends State<RideMapWidget> {
  GoogleMapController? _mapController;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _setupMarkers();
    _setupPolyline();
  }

  void _setupMarkers() {
    final originMarker = Marker(
      markerId: const MarkerId('origin'),
      position: LatLng(widget.ride.origin.lat, widget.ride.origin.lng),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(
        title: 'Origin',
        snippet: widget.ride.origin.address ?? 'Start point',
      ),
    );

    final destMarker = Marker(
      markerId: const MarkerId('destination'),
      position: LatLng(widget.ride.destination.lat, widget.ride.destination.lng),
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: InfoWindow(
        title: 'Destination',
        snippet: widget.ride.destination.address ?? 'End point',
      ),
    );

    setState(() {
      _markers = {originMarker, destMarker};
    });
  }

  void _setupPolyline() {
    // Create a simple straight line between origin and destination
    // In production, you would use Google Directions API to get the actual route
    final polyline = Polyline(
      polylineId: const PolylineId('route'),
      points: [
        LatLng(widget.ride.origin.lat, widget.ride.origin.lng),
        LatLng(widget.ride.destination.lat, widget.ride.destination.lng),
      ],
      color: AppTheme.primaryColor,
      width: 4,
      patterns: [PatternItem.dot, PatternItem.gap(10)],
    );

    setState(() {
      _polylines = {polyline};
    });
  }

  LatLngBounds _getBounds() {
    final origin = LatLng(widget.ride.origin.lat, widget.ride.origin.lng);
    final dest = LatLng(widget.ride.destination.lat, widget.ride.destination.lng);

    return LatLngBounds(
      southwest: LatLng(
        origin.latitude < dest.latitude ? origin.latitude : dest.latitude,
        origin.longitude < dest.longitude ? origin.longitude : dest.longitude,
      ),
      northeast: LatLng(
        origin.latitude > dest.latitude ? origin.latitude : dest.latitude,
        origin.longitude > dest.longitude ? origin.longitude : dest.longitude,
      ),
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final center = LatLng(
      (widget.ride.origin.lat + widget.ride.destination.lat) / 2,
      (widget.ride.origin.lng + widget.ride.destination.lng) / 2,
    );

    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: center,
            zoom: 12,
          ),
          onMapCreated: (controller) {
            _mapController = controller;
            // Fit bounds to show both markers
            try {
              final bounds = _getBounds();
              controller.animateCamera(
                CameraUpdate.newLatLngBounds(bounds, 50),
              );
            } catch (e) {
              // If bounds are invalid, keep default zoom
            }
          },
          markers: _markers,
          polylines: _polylines,
          myLocationButtonEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
          compassEnabled: false,
          rotateGesturesEnabled: false,
          scrollGesturesEnabled: true,
          zoomGesturesEnabled: true,
          tiltGesturesEnabled: false,
        ),
      ),
    );
  }
}

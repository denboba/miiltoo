import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
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
  bool _loadingRoute = false;

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

  Future<void> _setupPolyline() async {
    setState(() => _loadingRoute = true);
    
    try {
      // Attempt to get route from Google Directions API
      // Note: This requires a Google Maps API key with Directions API enabled
      // TODO: Move API key to environment variables or secure configuration
      const String apiKey = ''; // API key should be stored securely, not hardcoded
      
      if (apiKey.isEmpty) {
        // Skip API call if no key is configured
        throw Exception('Google Maps API key not configured');
      }
      
      // Only instantiate PolylinePoints if we have a valid API key
      PolylinePoints polylinePoints = PolylinePoints(apiKey: apiKey);
      
      PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: PointLatLng(widget.ride.origin.lat, widget.ride.origin.lng),
          destination: PointLatLng(widget.ride.destination.lat, widget.ride.destination.lng),
          mode: TravelMode.driving,
        ),
      );

      List<LatLng> polylineCoordinates = [];

      if (result.points.isNotEmpty) {
        // Use the route from Directions API
        for (var point in result.points) {
          polylineCoordinates.add(LatLng(point.latitude, point.longitude));
        }
      } else {
        // Fallback to straight line if API call fails or no API key
        polylineCoordinates = [
          LatLng(widget.ride.origin.lat, widget.ride.origin.lng),
          LatLng(widget.ride.destination.lat, widget.ride.destination.lng),
        ];
      }

      final polyline = Polyline(
        polylineId: const PolylineId('route'),
        points: polylineCoordinates,
        color: AppTheme.primaryColor,
        width: 5,
        // Use solid line for actual routes
        patterns: result.points.isEmpty ? [PatternItem.dot, PatternItem.gap(10)] : [],
      );

      setState(() {
        _polylines = {polyline};
        _loadingRoute = false;
      });
    } catch (e) {
      // Log error for debugging
      debugPrint('Failed to load route from Directions API: $e');
      
      // Fallback to simple straight line on error
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
        _loadingRoute = false;
      });
    }
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
      child: Stack(
        children: [
          ClipRRect(
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
          if (_loadingRoute)
            Positioned(
              bottom: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'Loading route...',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

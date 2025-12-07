import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/ride_model.dart';
import '../services/firestore_repo.dart';
import '../widgets/location_picker_widget.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

class CreateRideScreen extends StatefulWidget {
  const CreateRideScreen({super.key});

  @override
  State<CreateRideScreen> createState() => _CreateRideScreenState();
}

class _CreateRideScreenState extends State<CreateRideScreen> {
  final _formKey = GlobalKey<FormState>();
  final _originAddressController = TextEditingController();
  final _destAddressController = TextEditingController();
  final _notesController = TextEditingController();
  final FirestoreRepo _repo = FirestoreRepo();

  // Default coordinates (can be updated with map picker later)
  double _originLat = 0.0;
  double _originLng = 0.0;
  double _destLat = 0.0;
  double _destLng = 0.0;

  DateTime _selectedDate = DateTime.now().add(const Duration(hours: 1));
  TimeOfDay _selectedTime = TimeOfDay.now();
  int _seatsTotal = 1;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _selectedTime = TimeOfDay.fromDateTime(DateTime.now().add(const Duration(hours: 1)));
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _parseCoordinates(String text, bool isOrigin) {
    // Try to parse coordinates from text field (format: lat,lng)
    final parts = text.split(',');
    if (parts.length >= 2) {
      final lat = double.tryParse(parts[0].trim());
      final lng = double.tryParse(parts[1].trim());
      if (lat != null && lng != null) {
        if (isOrigin) {
          _originLat = lat;
          _originLng = lng;
        } else {
          _destLat = lat;
          _destLng = lng;
        }
      }
    }
  }

  void _pickOriginLocation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerWidget(
          initialLocation: _originLat != 0.0 && _originLng != 0.0
              ? LatLngPoint(lat: _originLat, lng: _originLng)
              : null,
          onLocationSelected: (location) {
            setState(() {
              _originLat = location.lat;
              _originLng = location.lng;
              // Display user-friendly address instead of coordinates
              _originAddressController.text = location.address ?? 'Origin Location';
            });
          },
          title: 'Select Origin',
        ),
      ),
    );
  }

  void _pickDestinationLocation() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LocationPickerWidget(
          initialLocation: _destLat != 0.0 && _destLng != 0.0
              ? LatLngPoint(lat: _destLat, lng: _destLng)
              : null,
          onLocationSelected: (location) {
            setState(() {
              _destLat = location.lat;
              _destLng = location.lng;
              // Display user-friendly address instead of coordinates
              _destAddressController.text = location.address ?? 'Destination Location';
            });
          },
          title: 'Select Destination',
        ),
      ),
    );
  }

  void _createRide() async {
    if (!_formKey.currentState!.validate()) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _error = 'You must be logged in to create a ride');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // Get user profile for driver name
      final userProfile = await _repo.getUserProfile(user.uid);
      final driverName = userProfile?.name ?? user.displayName ?? 'Unknown Driver';

      // Combine date and time
      final dateTime = DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      );

      final origin = LatLngPoint(
        lat: _originLat,
        lng: _originLng,
        address: _originAddressController.text.trim(),
      );

      final destination = LatLngPoint(
        lat: _destLat,
        lng: _destLng,
        address: _destAddressController.text.trim(),
      );

      final id = const Uuid().v4();
      final ride = Ride(
        id: id,
        driverId: user.uid,
        driverName: driverName,
        origin: origin,
        destination: destination,
        dateTime: dateTime,
        seatsTotal: _seatsTotal,
        seatsAvailable: _seatsTotal,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      );

      await _repo.createRide(ride);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ride created successfully!')),
      );
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  void dispose() {
    _originAddressController.dispose();
    _destAddressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Ride')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Origin Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.trip_origin, color: Theme.of(context).colorScheme.primary),
                          const SizedBox(width: 8),
                          const Text('Origin', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _originAddressController,
                        decoration: InputDecoration(
                          labelText: 'Origin Address',
                          hintText: 'e.g., 123 Main St, City',
                          prefixIcon: const Icon(Icons.location_on),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.map),
                            onPressed: _pickOriginLocation,
                            tooltip: 'Pick on Map',
                          ),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Please enter origin address' : null,
                        readOnly: false,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Destination Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.location_on, color: Theme.of(context).colorScheme.error),
                          const SizedBox(width: 8),
                          const Text('Destination', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _destAddressController,
                        decoration: InputDecoration(
                          labelText: 'Destination Address',
                          hintText: 'e.g., 456 Oak Ave, Town',
                          prefixIcon: const Icon(Icons.location_on),
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.map),
                            onPressed: _pickDestinationLocation,
                            tooltip: 'Pick on Map',
                          ),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty ? 'Please enter destination address' : null,
                        readOnly: false,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Date & Time Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.schedule, color: Colors.blue),
                          SizedBox(width: 8),
                          Text('When', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _selectDate,
                              icon: const Icon(Icons.calendar_today),
                              label: Text(DateFormat('MMM d, yyyy').format(_selectedDate)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: _selectTime,
                              icon: const Icon(Icons.access_time),
                              label: Text(_selectedTime.format(context)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Seats Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.event_seat, color: Colors.purple),
                          SizedBox(width: 8),
                          Text('Available Seats', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: _seatsTotal > 1 ? () => setState(() => _seatsTotal--) : null,
                            icon: const Icon(Icons.remove_circle_outline),
                            iconSize: 32,
                          ),
                          const SizedBox(width: 16),
                          Text(
                            '$_seatsTotal',
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            onPressed: _seatsTotal < 7 ? () => setState(() => _seatsTotal++) : null,
                            icon: const Icon(Icons.add_circle_outline),
                            iconSize: 32,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Notes Section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.notes, color: Colors.orange),
                          SizedBox(width: 8),
                          Text('Notes (optional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _notesController,
                        decoration: const InputDecoration(
                          hintText: 'Add any additional information...',
                          border: OutlineInputBorder(),
                        ),
                        maxLines: 3,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Error message
              if (_error != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_error!, style: const TextStyle(color: Colors.red)),
                ),
              if (_error != null) const SizedBox(height: 16),

              // Create Button
              ElevatedButton.icon(
                onPressed: _loading ? null : _createRide,
                icon: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.add),
                label: Text(_loading ? 'Creating...' : 'Create Ride'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
        ),
    );
  }
}


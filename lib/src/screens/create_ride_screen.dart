import 'package:flutter/material.dart';
import '../models/ride_model.dart';
import '../services/firestore_repo.dart';
import 'package:uuid/uuid.dart';

class CreateRideScreen extends StatefulWidget {
  const CreateRideScreen({super.key});

  @override
  State<CreateRideScreen> createState() => _CreateRideScreenState();
}

class _CreateRideScreenState extends State<CreateRideScreen> {
  final _originController = TextEditingController();
  final _destController = TextEditingController();
  final _dateController = TextEditingController();
  final _seatsController = TextEditingController(text: '1');
  final FirestoreRepo _repo = FirestoreRepo();
  bool _loading = false;
  String? _error;

  void _createRide() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // For MVP, parse coordinates from text fields as lat,lng pairs: "lat,lng|address"
      // Expect format: lat,lng|Address
      LatLngPoint parse(String s) {
        if (s.isEmpty) throw Exception('Empty');
        final parts = s.split('|');
        final coords = parts[0].split(',');
        final lat = double.parse(coords[0]);
        final lng = double.parse(coords[1]);
        final addr = parts.length > 1 ? parts[1] : null;
        return LatLngPoint(lat: lat, lng: lng, address: addr);
      }

      final origin = parse(_originController.text.trim());
      final dest = parse(_destController.text.trim());
      final date = DateTime.tryParse(_dateController.text.trim()) ?? DateTime.now().add(const Duration(hours: 1));
      final seatsTotal = int.tryParse(_seatsController.text.trim()) ?? 1;

      final id = const Uuid().v4();
      final ride = Ride(
        id: id,
        driverId: 'demo-driver', // TODO: replace with auth uid
        origin: origin,
        destination: dest,
        dateTime: date,
        seatsTotal: seatsTotal,
        seatsAvailable: seatsTotal,
        notes: null,
      );

      final rideId = await _repo.createRide(ride);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ride created: $rideId')));
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Ride')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text('Origin (format: lat,lng|Address)'),
              TextField(controller: _originController),
              const SizedBox(height: 8),
              const Text('Destination (format: lat,lng|Address)'),
              TextField(controller: _destController),
              const SizedBox(height: 8),
              const Text('Date/time (ISO 8601 or leave empty)'),
              TextField(controller: _dateController, decoration: const InputDecoration(hintText: '2025-12-31 15:30:00')),
              const SizedBox(height: 8),
              const Text('Total seats'),
              TextField(controller: _seatsController, keyboardType: TextInputType.number),
              const SizedBox(height: 12),
              if (_error != null) Text(_error!, style: const TextStyle(color: Colors.red)),
              ElevatedButton(onPressed: _loading ? null : _createRide, child: _loading ? const CircularProgressIndicator() : const Text('Create')),
            ],
          ),
        ),
      ),
    );
  }
}


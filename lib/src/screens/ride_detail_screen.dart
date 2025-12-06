import 'package:flutter/material.dart';
import '../models/ride_model.dart';
import '../services/firestore_repo.dart';
import 'chat_screen.dart';

class RideDetailScreen extends StatefulWidget {
  final Ride ride;
  const RideDetailScreen({super.key, required this.ride});

  @override
  State<RideDetailScreen> createState() => _RideDetailScreenState();
}

class _RideDetailScreenState extends State<RideDetailScreen> {
  final FirestoreRepo _repo = FirestoreRepo();
  bool _loading = false;

  void _requestSeat() async {
    setState(() => _loading = true);
    try {
      await _repo.createRequestTransactional(rideId: widget.ride.id, passengerId: 'demo-passenger');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request sent')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.ride;
    return Scaffold(
      appBar: AppBar(title: const Text('Ride Detail')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('From: ${r.origin.address ?? '${r.origin.lat},${r.origin.lng}'}'),
            Text('To: ${r.destination.address ?? '${r.destination.lat},${r.destination.lng}'}'),
            Text('When: ${r.dateTime.toLocal()}'),
            Text('Seats: ${r.seatsAvailable}/${r.seatsTotal}'),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: _loading ? null : _requestSeat, child: _loading ? const CircularProgressIndicator() : const Text('Request Seat')),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ChatScreen(rideId: r.id))), child: const Text('Open Chat')),
          ],
        ),
      ),
    );
  }
}

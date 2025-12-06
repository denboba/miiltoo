import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
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
  late Ride _ride;

  @override
  void initState() {
    super.initState();
    _ride = widget.ride;
  }

  bool get _isDriver {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    return uid != null && uid == _ride.driverId;
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'open':
        return Colors.green;
      case 'ongoing':
        return Colors.blue;
      case 'completed':
        return Colors.grey;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _requestSeat() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to request a seat')),
      );
      return;
    }

    if (_isDriver) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot request a seat on your own ride')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await _repo.createRequestTransactional(
        rideId: _ride.id,
        passengerId: user.uid,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request sent successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride Details'),
        actions: [
          if (_isDriver)
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'cancel') {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Cancel Ride'),
                      content: const Text('Are you sure you want to cancel this ride?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('No'),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Yes'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await _repo.updateRideStatus(_ride.id, 'cancelled');
                    if (!mounted) return;
                    Navigator.pop(context);
                  }
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'cancel', child: Text('Cancel Ride')),
              ],
            ),
        ],
      ),
      body: StreamBuilder<Ride?>(
        stream: _repo.rideStream(_ride.id),
        initialData: _ride,
        builder: (context, snapshot) {
          final ride = snapshot.data ?? _ride;
          _ride = ride;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Map placeholder
                Container(
                  height: 200,
                  color: Colors.grey.shade200,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.map, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 8),
                        Text(
                          'Route Map',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        Text(
                          '${ride.origin.lat.toStringAsFixed(4)}, ${ride.origin.lng.toStringAsFixed(4)} → ${ride.destination.lat.toStringAsFixed(4)}, ${ride.destination.lng.toStringAsFixed(4)}',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status Badge
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _getStatusColor(ride.status),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              ride.status.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (ride.seatsAvailable > 0)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.green.shade100,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                '${ride.seatsAvailable} seats available',
                                style: TextStyle(
                                  color: Colors.green.shade800,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Origin
                      _buildLocationRow(
                        icon: Icons.trip_origin,
                        color: Colors.green,
                        title: 'From',
                        address: ride.origin.address ?? '${ride.origin.lat}, ${ride.origin.lng}',
                      ),
                      const SizedBox(height: 16),

                      // Destination
                      _buildLocationRow(
                        icon: Icons.location_on,
                        color: Colors.red,
                        title: 'To',
                        address: ride.destination.address ?? '${ride.destination.lat}, ${ride.destination.lng}',
                      ),
                      const SizedBox(height: 24),

                      // Date & Time
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.schedule, color: Colors.blue),
                          title: Text(DateFormat('EEEE, MMM d, yyyy').format(ride.dateTime.toLocal())),
                          subtitle: Text(DateFormat('HH:mm').format(ride.dateTime.toLocal())),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Seats
                      Card(
                        child: ListTile(
                          leading: const Icon(Icons.event_seat, color: Colors.purple),
                          title: const Text('Available Seats'),
                          subtitle: Text('${ride.seatsAvailable} of ${ride.seatsTotal} seats'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: List.generate(
                              ride.seatsTotal,
                              (i) => Icon(
                                Icons.event_seat,
                                color: i < ride.seatsAvailable ? Colors.green : Colors.grey,
                                size: 24,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Driver
                      Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            child: Text(
                              (ride.driverName ?? 'D')[0].toUpperCase(),
                            ),
                          ),
                          title: Text(ride.driverName ?? 'Driver'),
                          subtitle: _isDriver ? const Text('You') : const Text('Driver'),
                          trailing: _isDriver
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.chat),
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => ChatScreen(rideId: ride.id)),
                                  ),
                                ),
                        ),
                      ),

                      // Notes
                      if (ride.notes != null && ride.notes!.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.notes, color: Colors.orange),
                            title: const Text('Notes'),
                            subtitle: Text(ride.notes!),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),

                      // Action Buttons
                      if (!_isDriver && ride.status == 'open' && ride.seatsAvailable > 0)
                        ElevatedButton.icon(
                          onPressed: _loading ? null : _requestSeat,
                          icon: _loading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Icon(Icons.add),
                          label: Text(_loading ? 'Requesting...' : 'Request a Seat'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            minimumSize: const Size(double.infinity, 48),
                          ),
                        ),

                      const SizedBox(height: 12),

                      OutlinedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ChatScreen(rideId: ride.id)),
                        ),
                        icon: const Icon(Icons.chat),
                        label: const Text('Open Chat'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLocationRow({
    required IconData icon,
    required Color color,
    required String title,
    required String address,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                address,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

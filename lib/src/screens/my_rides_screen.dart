import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/ride_model.dart';
import '../services/firestore_repo.dart';
import 'ride_detail_screen.dart';
import 'manage_requests_screen.dart';

class MyRidesScreen extends StatefulWidget {
  const MyRidesScreen({super.key});

  @override
  State<MyRidesScreen> createState() => _MyRidesScreenState();
}

class _MyRidesScreenState extends State<MyRidesScreen> {
  final FirestoreRepo _repo = FirestoreRepo();

  String _getStatusColor(String status) {
    switch (status) {
      case 'open':
        return 'green';
      case 'ongoing':
        return 'blue';
      case 'completed':
        return 'gray';
      case 'cancelled':
        return 'red';
      default:
        return 'gray';
    }
  }

  Color _getStatusColorValue(String status) {
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

  void _showStatusUpdateDialog(Ride ride) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Ride Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('Open'),
              leading: const Icon(Icons.check_circle_outline, color: Colors.green),
              onTap: () => _updateStatus(ride.id, 'open'),
            ),
            ListTile(
              title: const Text('Ongoing'),
              leading: const Icon(Icons.directions_car, color: Colors.blue),
              onTap: () => _updateStatus(ride.id, 'ongoing'),
            ),
            ListTile(
              title: const Text('Completed'),
              leading: const Icon(Icons.done_all, color: Colors.grey),
              onTap: () => _updateStatus(ride.id, 'completed'),
            ),
            ListTile(
              title: const Text('Cancelled'),
              leading: const Icon(Icons.cancel, color: Colors.red),
              onTap: () => _updateStatus(ride.id, 'cancelled'),
            ),
          ],
        ),
      ),
    );
  }

  void _updateStatus(String rideId, String status) async {
    Navigator.pop(context);
    try {
      await _repo.updateRideStatus(rideId, status);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ride status updated to $status')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in to view your rides')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Rides'),
      ),
      body: StreamBuilder<List<Ride>>(
        stream: _repo.driverRidesStream(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            print(snapshot.error);
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final rides = snapshot.data ?? [];
          if (rides.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.directions_car_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text(
                    'No rides yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/create'),
                    icon: const Icon(Icons.add),
                    label: const Text('Create a Ride'),
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: rides.length,
            itemBuilder: (context, idx) {
              final ride = rides[idx];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: _getStatusColorValue(ride.status),
                    child: const Icon(Icons.directions_car, color: Colors.white),
                  ),
                  title: Text(
                    '${ride.origin.address ?? '${ride.origin.lat.toStringAsFixed(2)},${ride.origin.lng.toStringAsFixed(2)}'} → ${ride.destination.address ?? '${ride.destination.lat.toStringAsFixed(2)},${ride.destination.lng.toStringAsFixed(2)}'}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        DateFormat('MMM d, yyyy - HH:mm').format(ride.dateTime.toLocal()),
                        style: const TextStyle(fontSize: 12),
                      ),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: _getStatusColorValue(ride.status).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              ride.status.toUpperCase(),
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: _getStatusColorValue(ride.status),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Seats: ${ride.seatsAvailable}/${ride.seatsTotal}',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      switch (value) {
                        case 'view':
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => RideDetailScreen(ride: ride)),
                          );
                          break;
                        case 'requests':
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ManageRequestsScreen(ride: ride)),
                          );
                          break;
                        case 'status':
                          _showStatusUpdateDialog(ride);
                          break;
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'view', child: Text('View Details')),
                      const PopupMenuItem(value: 'requests', child: Text('Manage Requests')),
                      const PopupMenuItem(value: 'status', child: Text('Update Status')),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RideDetailScreen(ride: ride)),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/create'),
        icon: const Icon(Icons.add),
        label: const Text('New Ride'),
      ),
    );
  }
}

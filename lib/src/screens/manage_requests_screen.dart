import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/ride_model.dart';
import '../models/request_model.dart';
import '../services/firestore_repo.dart';

class ManageRequestsScreen extends StatefulWidget {
  final Ride ride;

  const ManageRequestsScreen({super.key, required this.ride});

  @override
  State<ManageRequestsScreen> createState() => _ManageRequestsScreenState();
}

class _ManageRequestsScreenState extends State<ManageRequestsScreen> {
  final FirestoreRepo _repo = FirestoreRepo();

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'pending':
        return Icons.hourglass_empty;
      case 'accepted':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'cancelled':
        return Icons.block;
      default:
        return Icons.help;
    }
  }

  void _acceptRequest(RideRequest request) async {
    try {
      await _repo.acceptRequestTransactional(
        rideId: widget.ride.id,
        requestId: request.id,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request accepted')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _rejectRequest(RideRequest request) async {
    try {
      await _repo.rejectRequest(
        rideId: widget.ride.id,
        requestId: request.id,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request rejected')),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Requests'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Ride info header
            Container(
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${widget.ride.origin.address ?? 'Origin'} → ${widget.ride.destination.address ?? 'Destination'}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('MMM d, yyyy - HH:mm').format(widget.ride.dateTime.toLocal()),
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 4),
                Text(
                  'Available seats: ${widget.ride.seatsAvailable}/${widget.ride.seatsTotal}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          // Requests list
          Expanded(
            child: StreamBuilder<List<RideRequest>>(
              stream: _repo.rideRequestsStream(widget.ride.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final requests = snapshot.data ?? [];
                if (requests.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No requests yet',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }
                return ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: requests.length,
                  itemBuilder: (context, idx) {
                    final request = requests[idx];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 4),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: _getStatusColor(request.status),
                                  child: Icon(
                                    _getStatusIcon(request.status),
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        request.passengerName ?? 'Passenger ${request.passengerId.substring(0, 8)}...',
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      Text(
                                        'Requested: ${request.seatsRequested} seat(s)',
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                      Text(
                                        DateFormat('MMM d, yyyy - HH:mm').format(request.createdAt.toLocal()),
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: _getStatusColor(request.status).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    request.status.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: _getStatusColor(request.status),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            if (request.status == 'pending') ...[
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  OutlinedButton.icon(
                                    onPressed: () => _rejectRequest(request),
                                    icon: const Icon(Icons.close),
                                    label: const Text('Reject'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton.icon(
                                    onPressed: () => _acceptRequest(request),
                                    icon: const Icon(Icons.check),
                                    label: const Text('Accept'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
        ),
    );
  }
}

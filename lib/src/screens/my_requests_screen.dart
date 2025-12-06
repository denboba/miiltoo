import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../models/request_model.dart';
import '../models/ride_model.dart';
import '../services/firestore_repo.dart';
import '../config/app_theme.dart';
import 'ride_detail_screen.dart';
import 'chat_screen.dart';

class MyRequestsScreen extends StatefulWidget {
  const MyRequestsScreen({super.key});

  @override
  State<MyRequestsScreen> createState() => _MyRequestsScreenState();
}

class _MyRequestsScreenState extends State<MyRequestsScreen> {
  final FirestoreRepo _repo = FirestoreRepo();
  bool _loading = true;
  List<Map<String, dynamic>> _requestsWithRides = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadRequests();
  }

  void _loadRequests() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() {
        _loading = false;
        _error = 'Not logged in';
      });
      return;
    }

    try {
      final requests = await _repo.getPassengerRequests(uid);
      setState(() {
        _requestsWithRides = requests;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    return AppTheme.getStatusColor(status);
  }

  IconData _getStatusIcon(String status) {
    return AppTheme.getStatusIcon(status);
  }

  void _cancelRequest(RideRequest request) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancel Request'),
        content: const Text('Are you sure you want to cancel this request?'),
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

    if (confirm != true) return;

    try {
      await _repo.cancelRequest(
        rideId: request.rideId,
        requestId: request.id,
        seatsRequested: request.seatsRequested,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request cancelled')),
      );
      _loadRequests();
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
        title: const Text('My Requests'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() => _loading = true);
              _loadRequests();
            },
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? GestureDetector(
        child: Center(child: Text(_error!),),
         onTap: (){
           print(_error);

         },


      )
              : _requestsWithRides.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.inbox, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text(
                            'No requests yet',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () => Navigator.pushNamed(context, '/search'),
                            icon: const Icon(Icons.search),
                            label: const Text('Find a Ride'),
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () async {
                        _loadRequests();
                      },
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8),
                        itemCount: _requestsWithRides.length,
                        itemBuilder: (context, idx) {
                          final item = _requestsWithRides[idx];
                          final request = item['request'] as RideRequest;
                          final ride = item['ride'] as Ride?;

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
                                            if (ride != null)
                                              Text(
                                                '${ride.origin.address ?? 'Origin'} → ${ride.destination.address ?? 'Destination'}',
                                                style: const TextStyle(fontWeight: FontWeight.bold),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            if (ride != null)
                                              Text(
                                                DateFormat('MMM d, yyyy - HH:mm').format(ride.dateTime.toLocal()),
                                                style: const TextStyle(fontSize: 12, color: Colors.grey),
                                              ),
                                            Text(
                                              'Seats requested: ${request.seatsRequested}',
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
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (ride != null) ...[
                                        TextButton.icon(
                                          onPressed: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(builder: (_) => RideDetailScreen(ride: ride)),
                                          ),
                                          icon: const Icon(Icons.info_outline),
                                          label: const Text('Details'),
                                        ),
                                        if (request.status == 'accepted')
                                          TextButton.icon(
                                            onPressed: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (_) => ChatScreen(rideId: ride.id)),
                                            ),
                                            icon: const Icon(Icons.chat),
                                            label: const Text('Chat'),
                                          ),
                                      ],
                                      if (request.status == 'pending' || request.status == 'accepted')
                                        TextButton.icon(
                                          onPressed: () => _cancelRequest(request),
                                          icon: const Icon(Icons.cancel, color: Colors.red),
                                          label: const Text('Cancel', style: TextStyle(color: Colors.red)),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}

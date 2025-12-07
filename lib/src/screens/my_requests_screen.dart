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
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                        const SizedBox(height: 16),
                        Text(
                          'Error loading requests',
                          style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            _error!,
                            style: const TextStyle(fontSize: 14, color: Colors.grey),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() => _loading = true);
                            _loadRequests();
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
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
                        padding: const EdgeInsets.all(16),
                        itemCount: _requestsWithRides.length,
                        itemBuilder: (context, idx) {
                          final item = _requestsWithRides[idx];
                          final request = item['request'] as RideRequest;
                          final ride = item['ride'] as Ride?;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 2,
                            shadowColor: _getStatusColor(request.status).withOpacity(0.2),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: _getStatusColor(request.status).withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: ride != null
                                  ? () => Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (_) => RideDetailScreen(ride: ride)),
                                      )
                                  : null,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(request.status).withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            _getStatusIcon(request.status),
                                            color: _getStatusColor(request.status),
                                            size: 24,
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
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 15,
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              if (ride != null) const SizedBox(height: 4),
                                              if (ride != null)
                                                Row(
                                                  children: [
                                                    Icon(Icons.access_time, size: 14, color: Colors.grey.shade600),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      DateFormat('MMM d, yyyy - HH:mm').format(ride.dateTime.toLocal()),
                                                      style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                                    ),
                                                  ],
                                                ),
                                              const SizedBox(height: 4),
                                              Row(
                                                children: [
                                                  Icon(Icons.event_seat, size: 14, color: Colors.grey.shade600),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    '${request.seatsRequested} seat${request.seatsRequested > 1 ? 's' : ''}',
                                                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: _getStatusColor(request.status).withOpacity(0.15),
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            request.status.toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: _getStatusColor(request.status),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
                                    const Divider(height: 1),
                                    const SizedBox(height: 8),
                                    Wrap(
                                      spacing: 8,
                                      runSpacing: 8,
                                      alignment: WrapAlignment.end,
                                      children: [
                                        if (ride != null && request.status == 'accepted')
                                          OutlinedButton.icon(
                                            onPressed: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(builder: (_) => ChatScreen(rideId: ride.id)),
                                            ),
                                            icon: const Icon(Icons.chat, size: 18),
                                            label: const Text('Chat'),
                                            style: OutlinedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                            ),
                                          ),
                                        if (request.status == 'pending' || request.status == 'accepted')
                                          OutlinedButton.icon(
                                            onPressed: () => _cancelRequest(request),
                                            icon: const Icon(Icons.cancel, size: 18, color: Colors.red),
                                            label: const Text('Cancel', style: TextStyle(color: Colors.red)),
                                            style: OutlinedButton.styleFrom(
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              side: const BorderSide(color: Colors.red),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
      ),
    );
  }
}

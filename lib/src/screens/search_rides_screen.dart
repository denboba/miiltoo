import 'package:flutter/material.dart';
import '../services/firestore_repo.dart';
import '../models/ride_model.dart';
import 'package:miiltoo/src/screens/ride_detail_screen.dart';

class SearchRidesScreen extends StatefulWidget {
  const SearchRidesScreen({super.key});

  @override
  State<SearchRidesScreen> createState() => _SearchRidesScreenState();
}

class _SearchRidesScreenState extends State<SearchRidesScreen> {
  final _repo = FirestoreRepo();
  List<Ride> _rides = [];
  bool _loading = false;

  void _search() async {
    setState(() => _loading = true);
    try {
      final results = await _repo.searchRides(originLat: 0, originLng: 0);
      setState(() => _rides = results);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _search();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Rides')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _rides.length,
              itemBuilder: (context, idx) {
                final r = _rides[idx];
                return ListTile(
                  title: Text('${r.origin.address ?? '${r.origin.lat},${r.origin.lng}'} → ${r.destination.address ?? ''}'),
                  subtitle: Text('Seats: ${r.seatsAvailable}/${r.seatsTotal} — ${r.dateTime.toLocal()}'),
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => RideDetailScreen(ride: r)));
                  },
                );
              },
            ),
    );
  }
}

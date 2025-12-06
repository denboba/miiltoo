import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ride_model.dart';

class FirestoreRepo {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get ridesRef => _db.collection('rides');
  CollectionReference get usersRef => _db.collection('users');

  Future<String> createRide(Ride ride) async {
    final doc = await ridesRef.add(ride.toMap());
    return doc.id;
  }

  Future<List<Ride>> searchRides({required double originLat, required double originLng, double radiusKm = 10, DateTime? date}) async {
    // Simplified search: returns rides with scheduled date on the same day if provided.
    Query q = ridesRef.where('status', isEqualTo: 'open');
    if (date != null) {
      final start = DateTime(date.year, date.month, date.day);
      final end = start.add(Duration(days: 1));
      q = q.where('dateTime', isGreaterThanOrEqualTo: start.toUtc()).where('dateTime', isLessThan: end.toUtc());
    }
    final snapshot = await q.get();
    return snapshot.docs.map((d) => Ride.fromMap(d.id, d.data() as Map<String, dynamic>)).toList();
  }

  Future<void> createRequestTransactional({required String rideId, required String passengerId, int seatsRequested = 1}) async {
    final rideDoc = ridesRef.doc(rideId);
    final requestsRef = rideDoc.collection('requests');

    return _db.runTransaction((tx) async {
      final snapshot = await tx.get(rideDoc);
      if (!snapshot.exists) throw Exception('Ride not found');
      final data = snapshot.data() as Map<String, dynamic>;
      int seatsAvailable = (data['seatsAvailable'] as num).toInt();
      if (seatsAvailable < seatsRequested) {
        throw Exception('Not enough seats available');
      }
      seatsAvailable -= seatsRequested;
      tx.update(rideDoc, {'seatsAvailable': seatsAvailable});

      final newReqRef = requestsRef.doc();
      tx.set(newReqRef, {
        'rideId': rideId,
        'passengerId': passengerId,
        'status': 'pending',
        'seatsRequested': seatsRequested,
        'createdAt': DateTime.now().toUtc(),
      });
    });
  }

  Future<void> acceptRequestTransactional({required String rideId, required String requestId}) async {
    final rideDoc = ridesRef.doc(rideId);
    final reqDoc = rideDoc.collection('requests').doc(requestId);

    return _db.runTransaction((tx) async {
      final rideSnap = await tx.get(rideDoc);
      final requestSnap = await tx.get(reqDoc);
      if (!rideSnap.exists) throw Exception('Ride not found');
      if (!requestSnap.exists) throw Exception('Request not found');

      final rideData = rideSnap.data() as Map<String, dynamic>;
      final reqData = requestSnap.data() as Map<String, dynamic>;
      int seatsAvailable = (rideData['seatsAvailable'] as num).toInt();
      int seatsRequested = (reqData['seatsRequested'] as num).toInt();

      if (seatsAvailable < seatsRequested) throw Exception('Not enough seats');

      seatsAvailable -= seatsRequested;
      tx.update(rideDoc, {'seatsAvailable': seatsAvailable});
      tx.update(reqDoc, {'status': 'accepted', 'updatedAt': DateTime.now().toUtc()});
    });
  }

  Future<void> createUserProfile({required String uid, required String name, required String email, String? phone, String role = 'passenger', String? profilePicUrl}) async {
    final doc = usersRef.doc(uid);
    await doc.set({
      'name': name,
      'email': email,
      'phone': phone ?? '',
      'role': role,
      'profilePicUrl': profilePicUrl ?? '',
      'createdAt': DateTime.now().toUtc(),
    });
  }
}

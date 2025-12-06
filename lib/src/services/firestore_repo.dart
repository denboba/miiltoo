import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/ride_model.dart';
import '../models/request_model.dart';
import '../models/user_model.dart';
import '../models/message_model.dart';

class FirestoreRepo {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference get ridesRef => _db.collection('rides');
  CollectionReference get usersRef => _db.collection('users');

  // ==================== RIDE METHODS ====================

  Future<String> createRide(Ride ride) async {
    final doc = await ridesRef.add(ride.toMap());
    return doc.id;
  }

  Future<Ride?> getRide(String rideId) async {
    final doc = await ridesRef.doc(rideId).get();
    if (!doc.exists) return null;
    return Ride.fromMap(doc.id, doc.data() as Map<String, dynamic>);
  }

  Stream<Ride?> rideStream(String rideId) {
    return ridesRef.doc(rideId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return Ride.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    });
  }

  Future<List<Ride>> searchRides({required double originLat, required double originLng, double radiusKm = 10, DateTime? date}) async {
    // Simplified search: returns rides with scheduled date on the same day if provided.
    Query q = ridesRef.where('status', isEqualTo: 'open');
    if (date != null) {
      final start = DateTime(date.year, date.month, date.day);
      final end = start.add(const Duration(days: 1));
      q = q.where('dateTime', isGreaterThanOrEqualTo: start.toUtc()).where('dateTime', isLessThan: end.toUtc());
    }
    final snapshot = await q.get();
    return snapshot.docs.map((d) => Ride.fromMap(d.id, d.data() as Map<String, dynamic>)).toList();
  }

  Stream<List<Ride>> searchRidesStream({DateTime? date}) {
    Query q = ridesRef.where('status', isEqualTo: 'open');
    if (date != null) {
      final start = DateTime(date.year, date.month, date.day);
      final end = start.add(const Duration(days: 1));
      q = q.where('dateTime', isGreaterThanOrEqualTo: start.toUtc()).where('dateTime', isLessThan: end.toUtc());
    }
    return q.snapshots().map((snapshot) =>
        snapshot.docs.map((d) => Ride.fromMap(d.id, d.data() as Map<String, dynamic>)).toList());
  }

  Future<List<Ride>> getDriverRides(String driverId) async {
    final snapshot = await ridesRef.where('driverId', isEqualTo: driverId).orderBy('dateTime', descending: true).get();
    return snapshot.docs.map((d) => Ride.fromMap(d.id, d.data() as Map<String, dynamic>)).toList();
  }

  Stream<List<Ride>> driverRidesStream(String driverId) {
    return ridesRef
        .where('driverId', isEqualTo: driverId)
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((d) => Ride.fromMap(d.id, d.data() as Map<String, dynamic>)).toList());
  }

  Future<void> updateRideStatus(String rideId, String status) async {
    await ridesRef.doc(rideId).update({
      'status': status,
      'updatedAt': DateTime.now().toUtc(),
    });
  }

  Future<void> deleteRide(String rideId) async {
    await ridesRef.doc(rideId).delete();
  }

  // ==================== REQUEST METHODS ====================

  Future<void> createRequestTransactional({required String rideId, required String passengerId, int seatsRequested = 1}) async {
    final rideDoc = ridesRef.doc(rideId);
    final requestsRef = rideDoc.collection('requests');

    // Check if passenger already has a pending/accepted request for this ride
    final existingRequests = await requestsRef
        .where('passengerId', isEqualTo: passengerId)
        .where('status', whereIn: ['pending', 'accepted'])
        .get();

    if (existingRequests.docs.isNotEmpty) {
      throw Exception('You already have a pending or accepted request for this ride');
    }

    return _db.runTransaction((tx) async {
      final snapshot = await tx.get(rideDoc);
      if (!snapshot.exists) throw Exception('Ride not found');
      final data = snapshot.data() as Map<String, dynamic>;
      int seatsAvailable = (data['seatsAvailable'] as num).toInt();
      if (seatsAvailable < seatsRequested) {
        throw Exception('Not enough seats available');
      }

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

  Future<void> rejectRequest({required String rideId, required String requestId}) async {
    final reqDoc = ridesRef.doc(rideId).collection('requests').doc(requestId);
    await reqDoc.update({
      'status': 'rejected',
      'updatedAt': DateTime.now().toUtc(),
    });
  }

  Future<void> cancelRequest({required String rideId, required String requestId, required int seatsRequested}) async {
    final rideDoc = ridesRef.doc(rideId);
    final reqDoc = rideDoc.collection('requests').doc(requestId);

    return _db.runTransaction((tx) async {
      final requestSnap = await tx.get(reqDoc);
      if (!requestSnap.exists) throw Exception('Request not found');

      final reqData = requestSnap.data() as Map<String, dynamic>;
      final status = reqData['status'] as String? ?? 'pending';

      // If the request was accepted, restore the seats
      if (status == 'accepted') {
        final rideSnap = await tx.get(rideDoc);
        if (rideSnap.exists) {
          final rideData = rideSnap.data() as Map<String, dynamic>;
          int seatsAvailable = (rideData['seatsAvailable'] as num).toInt();
          seatsAvailable += seatsRequested;
          tx.update(rideDoc, {'seatsAvailable': seatsAvailable});
        }
      }

      tx.update(reqDoc, {'status': 'cancelled', 'updatedAt': DateTime.now().toUtc()});
    });
  }

  Future<List<RideRequest>> getRideRequests(String rideId) async {
    final snapshot = await ridesRef.doc(rideId).collection('requests').orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((d) => RideRequest.fromMap(d.id, d.data())).toList();
  }

  Stream<List<RideRequest>> rideRequestsStream(String rideId) {
    return ridesRef
        .doc(rideId)
        .collection('requests')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((d) => RideRequest.fromMap(d.id, d.data())).toList());
  }

  // Get all requests made by a passenger across all rides
  Future<List<Map<String, dynamic>>> getPassengerRequests(String passengerId) async {
    // Since requests are subcollections, we need to use collection group query
    final snapshot = await _db
        .collectionGroup('requests')
        .where('passengerId', isEqualTo: passengerId)
        .orderBy('createdAt', descending: true)
        .get();

    List<Map<String, dynamic>> result = [];
    for (var doc in snapshot.docs) {
      final request = RideRequest.fromMap(doc.id, doc.data());
      // Get the ride info
      final rideId = request.rideId;
      final ride = await getRide(rideId);
      result.add({
        'request': request,
        'ride': ride,
      });
    }
    return result;
  }

  Stream<List<RideRequest>> passengerRequestsStream(String passengerId) {
    return _db
        .collectionGroup('requests')
        .where('passengerId', isEqualTo: passengerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((d) => RideRequest.fromMap(d.id, d.data())).toList());
  }

  // ==================== USER METHODS ====================

  Future<void> createUserProfile({required String uid, required String name, required String email, String? phone, String role = 'passenger', String? profilePicUrl}) async {
    final doc = usersRef.doc(uid);
    await doc.set({
      'uid': uid,
      'name': name,
      'email': email,
      'phone': phone ?? '',
      'role': role,
      'photoUrl': profilePicUrl ?? '',
      'createdAt': DateTime.now().toUtc(),
    });
  }

  Future<UserModel?> getUserProfile(String uid) async {
    final doc = await usersRef.doc(uid).get();
    if (!doc.exists) return null;
    final data = doc.data() as Map<String, dynamic>;
    data['uid'] = uid;
    return UserModel.fromMap(data);
  }

  Stream<UserModel?> userProfileStream(String uid) {
    return usersRef.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      final data = doc.data() as Map<String, dynamic>;
      data['uid'] = uid;
      return UserModel.fromMap(data);
    });
  }

  Future<void> updateUserProfile({required String uid, String? name, String? phone, String? role, String? photoUrl}) async {
    final Map<String, dynamic> updates = {
      'updatedAt': DateTime.now().toUtc(),
    };
    if (name != null) updates['name'] = name;
    if (phone != null) updates['phone'] = phone;
    if (role != null) updates['role'] = role;
    if (photoUrl != null) updates['photoUrl'] = photoUrl;

    await usersRef.doc(uid).update(updates);
  }

  // ==================== MESSAGE METHODS ====================

  Future<void> sendMessage({required String rideId, required String senderId, required String text}) async {
    await ridesRef.doc(rideId).collection('messages').add({
      'senderId': senderId,
      'text': text,
      'createdAt': DateTime.now().toUtc(),
    });
  }

  Stream<List<Message>> messagesStream(String rideId) {
    return ridesRef
        .doc(rideId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((d) => Message.fromMap(d.id, d.data())).toList());
  }

  Future<List<Message>> getMessages(String rideId) async {
    final snapshot = await ridesRef.doc(rideId).collection('messages').orderBy('createdAt', descending: true).get();
    return snapshot.docs.map((d) => Message.fromMap(d.id, d.data())).toList();
  }
}

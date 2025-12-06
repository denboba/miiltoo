import 'package:flutter_test/flutter_test.dart';
import 'package:miiltoo/src/models/ride_model.dart';
import 'package:miiltoo/src/models/user_model.dart';
import 'package:miiltoo/src/models/request_model.dart';
import 'package:miiltoo/src/models/message_model.dart';

void main() {
  group('Ride Model', () {
    test('Ride model serialization roundtrip', () {
      final origin = LatLngPoint(lat: 1.0, lng: 2.0, address: 'A');
      final dest = LatLngPoint(lat: 3.0, lng: 4.0, address: 'B');
      final ride = Ride(
        id: 'r1',
        driverId: 'd1',
        origin: origin,
        destination: dest,
        dateTime: DateTime.now(),
        seatsTotal: 3,
        seatsAvailable: 3,
        driverName: 'Test Driver',
      );
      final map = ride.toMap();
      final parsed = Ride.fromMap('r1', map);
      expect(parsed.driverId, ride.driverId);
      expect(parsed.seatsTotal, ride.seatsTotal);
      expect(parsed.driverName, ride.driverName);
    });

    test('Ride copyWith creates new instance with updated values', () {
      final origin = LatLngPoint(lat: 1.0, lng: 2.0, address: 'A');
      final dest = LatLngPoint(lat: 3.0, lng: 4.0, address: 'B');
      final ride = Ride(
        id: 'r1',
        driverId: 'd1',
        origin: origin,
        destination: dest,
        dateTime: DateTime.now(),
        seatsTotal: 3,
        seatsAvailable: 3,
      );
      final updated = ride.copyWith(seatsAvailable: 2, status: 'ongoing');
      expect(updated.seatsAvailable, 2);
      expect(updated.status, 'ongoing');
      expect(updated.id, ride.id);
      expect(updated.driverId, ride.driverId);
    });

    test('LatLngPoint copyWith works correctly', () {
      final point = LatLngPoint(lat: 1.0, lng: 2.0, address: 'Test');
      final updated = point.copyWith(lat: 3.0);
      expect(updated.lat, 3.0);
      expect(updated.lng, 2.0);
      expect(updated.address, 'Test');
    });
  });

  group('User Model', () {
    test('UserModel serialization roundtrip', () {
      final user = UserModel(
        uid: 'u1',
        name: 'Test User',
        email: 'test@example.com',
        phone: '123456789',
        role: 'driver',
      );
      final map = user.toMap();
      final parsed = UserModel.fromMap(map);
      expect(parsed.uid, user.uid);
      expect(parsed.name, user.name);
      expect(parsed.email, user.email);
      expect(parsed.role, user.role);
    });

    test('UserModel copyWith works correctly', () {
      final user = UserModel(
        uid: 'u1',
        name: 'Test User',
        email: 'test@example.com',
        role: 'passenger',
      );
      final updated = user.copyWith(name: 'New Name', role: 'driver');
      expect(updated.name, 'New Name');
      expect(updated.role, 'driver');
      expect(updated.uid, user.uid);
      expect(updated.email, user.email);
    });
  });

  group('Request Model', () {
    test('RideRequest serialization roundtrip', () {
      final request = RideRequest(
        id: 'req1',
        rideId: 'r1',
        passengerId: 'p1',
        status: 'pending',
        seatsRequested: 2,
      );
      final map = request.toMap();
      final parsed = RideRequest.fromMap('req1', map);
      expect(parsed.rideId, request.rideId);
      expect(parsed.passengerId, request.passengerId);
      expect(parsed.status, request.status);
      expect(parsed.seatsRequested, request.seatsRequested);
    });

    test('RideRequest copyWith works correctly', () {
      final request = RideRequest(
        id: 'req1',
        rideId: 'r1',
        passengerId: 'p1',
        status: 'pending',
      );
      final updated = request.copyWith(status: 'accepted');
      expect(updated.status, 'accepted');
      expect(updated.id, request.id);
      expect(updated.rideId, request.rideId);
    });
  });

  group('Message Model', () {
    test('Message serialization roundtrip', () {
      final message = Message(
        id: 'm1',
        senderId: 's1',
        text: 'Hello',
        senderName: 'Test Sender',
      );
      final map = message.toMap();
      final parsed = Message.fromMap('m1', map);
      expect(parsed.senderId, message.senderId);
      expect(parsed.text, message.text);
      expect(parsed.senderName, message.senderName);
    });

    test('Message copyWith works correctly', () {
      final message = Message(
        id: 'm1',
        senderId: 's1',
        text: 'Hello',
      );
      final updated = message.copyWith(text: 'Updated text');
      expect(updated.text, 'Updated text');
      expect(updated.id, message.id);
      expect(updated.senderId, message.senderId);
    });
  });
}

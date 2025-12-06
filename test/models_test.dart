import 'package:flutter_test/flutter_test.dart';
import 'package:miiltoo/src/models/ride_model.dart';

void main() {
  test('Ride model serialization roundtrip', () {
    final origin = LatLngPoint(lat: 1.0, lng: 2.0, address: 'A');
    final dest = LatLngPoint(lat: 3.0, lng: 4.0, address: 'B');
    final ride = Ride(id: 'r1', driverId: 'd1', origin: origin, destination: dest, dateTime: DateTime.now(), seatsTotal: 3, seatsAvailable: 3);
    final map = ride.toMap();
    final parsed = Ride.fromMap('r1', map);
    expect(parsed.driverId, ride.driverId);
    expect(parsed.seatsTotal, ride.seatsTotal);
  });
}


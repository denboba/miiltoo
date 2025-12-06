import 'package:cloud_firestore/cloud_firestore.dart';

class LatLngPoint {
  final double lat;
  final double lng;
  final String? address;

  LatLngPoint({required this.lat, required this.lng, this.address});

  Map<String, dynamic> toMap() => {
        'lat': lat,
        'lng': lng,
        'address': address,
      };

  factory LatLngPoint.fromMap(Map<String, dynamic> map) => LatLngPoint(
        lat: (map['lat'] as num).toDouble(),
        lng: (map['lng'] as num).toDouble(),
        address: map['address'] as String?,
      );

  LatLngPoint copyWith({double? lat, double? lng, String? address}) {
    return LatLngPoint(
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      address: address ?? this.address,
    );
  }
}

class Ride {
  final String id;
  final String driverId;
  final LatLngPoint origin;
  final LatLngPoint destination;
  final DateTime dateTime;
  final int seatsTotal;
  final int seatsAvailable;
  final String status; // open, ongoing, completed, cancelled
  final String? notes;
  final String? driverName;

  Ride({
    required this.id,
    required this.driverId,
    required this.origin,
    required this.destination,
    required this.dateTime,
    required this.seatsTotal,
    required this.seatsAvailable,
    this.status = 'open',
    this.notes,
    this.driverName,
  });

  Ride copyWith({
    String? id,
    String? driverId,
    LatLngPoint? origin,
    LatLngPoint? destination,
    DateTime? dateTime,
    int? seatsTotal,
    int? seatsAvailable,
    String? status,
    String? notes,
    String? driverName,
  }) {
    return Ride(
      id: id ?? this.id,
      driverId: driverId ?? this.driverId,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      dateTime: dateTime ?? this.dateTime,
      seatsTotal: seatsTotal ?? this.seatsTotal,
      seatsAvailable: seatsAvailable ?? this.seatsAvailable,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      driverName: driverName ?? this.driverName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'driverId': driverId,
      'origin': origin.toMap(),
      'destination': destination.toMap(),
      'dateTime': dateTime.toUtc(),
      'seatsTotal': seatsTotal,
      'seatsAvailable': seatsAvailable,
      'status': status,
      'notes': notes,
      'driverName': driverName,
      'createdAt': DateTime.now(),
    };
  }

  factory Ride.fromMap(String id, Map<String, dynamic> map) {
    DateTime parsedDateTime;
    final dateTimeValue = map['dateTime'];
    if (dateTimeValue is DateTime) {
      parsedDateTime = dateTimeValue;
    } else if (dateTimeValue is Timestamp) {
      parsedDateTime = dateTimeValue.toDate();
    } else {
      parsedDateTime = DateTime.parse(dateTimeValue.toString());
    }

    return Ride(
      id: id,
      driverId: map['driverId'] as String? ?? '',
      origin: LatLngPoint.fromMap(Map<String, dynamic>.from(map['origin'])),
      destination: LatLngPoint.fromMap(Map<String, dynamic>.from(map['destination'])),
      dateTime: parsedDateTime,
      seatsTotal: (map['seatsTotal'] as num).toInt(),
      seatsAvailable: (map['seatsAvailable'] as num).toInt(),
      status: map['status'] as String? ?? 'open',
      notes: map['notes'] as String?,
      driverName: map['driverName'] as String?,
    );
  }
}



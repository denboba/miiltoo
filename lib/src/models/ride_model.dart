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
  });

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
      'createdAt': DateTime.now(),
    };
  }

  factory Ride.fromMap(String id, Map<String, dynamic> map) {
    return Ride(
      id: id,
      driverId: map['driverId'] as String? ?? '',
      origin: LatLngPoint.fromMap(Map<String, dynamic>.from(map['origin'])),
      destination: LatLngPoint.fromMap(Map<String, dynamic>.from(map['destination'])),
      dateTime: (map['dateTime'] as DateTime?) ?? DateTime.parse(map['dateTime'].toString()),
      seatsTotal: (map['seatsTotal'] as num).toInt(),
      seatsAvailable: (map['seatsAvailable'] as num).toInt(),
      status: map['status'] as String? ?? 'open',
      notes: map['notes'] as String?,
    );
  }
}


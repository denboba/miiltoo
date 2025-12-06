class RideRequest {
  final String id;
  final String rideId;
  final String passengerId;
  final String status; // pending, accepted, rejected, cancelled
  final int seatsRequested;
  final DateTime createdAt;

  RideRequest({
    required this.id,
    required this.rideId,
    required this.passengerId,
    this.status = 'pending',
    this.seatsRequested = 1,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'rideId': rideId,
      'passengerId': passengerId,
      'status': status,
      'seatsRequested': seatsRequested,
      'createdAt': createdAt.toUtc(),
    };
  }

  factory RideRequest.fromMap(String id, Map<String, dynamic> map) {
    return RideRequest(
      id: id,
      rideId: map['rideId'] as String? ?? '',
      passengerId: map['passengerId'] as String? ?? '',
      status: map['status'] as String? ?? 'pending',
      seatsRequested: (map['seatsRequested'] as num?)?.toInt() ?? 1,
      createdAt: (map['createdAt'] as DateTime?) ?? DateTime.parse(map['createdAt'].toString()),
    );
  }
}


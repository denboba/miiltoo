import 'package:cloud_firestore/cloud_firestore.dart';

class RideRequest {
  final String id;
  final String rideId;
  final String passengerId;
  final String status; // pending, accepted, rejected, cancelled
  final int seatsRequested;
  final DateTime createdAt;
  final String? passengerName;

  RideRequest({
    required this.id,
    required this.rideId,
    required this.passengerId,
    this.status = 'pending',
    this.seatsRequested = 1,
    DateTime? createdAt,
    this.passengerName,
  }) : createdAt = createdAt ?? DateTime.now();

  RideRequest copyWith({
    String? id,
    String? rideId,
    String? passengerId,
    String? status,
    int? seatsRequested,
    DateTime? createdAt,
    String? passengerName,
  }) {
    return RideRequest(
      id: id ?? this.id,
      rideId: rideId ?? this.rideId,
      passengerId: passengerId ?? this.passengerId,
      status: status ?? this.status,
      seatsRequested: seatsRequested ?? this.seatsRequested,
      createdAt: createdAt ?? this.createdAt,
      passengerName: passengerName ?? this.passengerName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'rideId': rideId,
      'passengerId': passengerId,
      'status': status,
      'seatsRequested': seatsRequested,
      'createdAt': createdAt.toUtc(),
      'passengerName': passengerName,
    };
  }

  factory RideRequest.fromMap(String id, Map<String, dynamic> map) {
    DateTime parsedCreatedAt;
    final createdAtValue = map['createdAt'];
    if (createdAtValue is DateTime) {
      parsedCreatedAt = createdAtValue;
    } else if (createdAtValue is Timestamp) {
      parsedCreatedAt = createdAtValue.toDate();
    } else if (createdAtValue != null) {
      parsedCreatedAt = DateTime.parse(createdAtValue.toString());
    } else {
      parsedCreatedAt = DateTime.now();
    }

    return RideRequest(
      id: id,
      rideId: map['rideId'] as String? ?? '',
      passengerId: map['passengerId'] as String? ?? '',
      status: map['status'] as String? ?? 'pending',
      seatsRequested: (map['seatsRequested'] as num?)?.toInt() ?? 1,
      createdAt: parsedCreatedAt,
      passengerName: map['passengerName'] as String?,
    );
  }
}



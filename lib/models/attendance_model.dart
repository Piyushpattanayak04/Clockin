// lib/models/attendance_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

class Attendance {
  final String id;
  final String userId;
  final String eventId;
  final DateTime timestamp;
  final bool isPresent;

  Attendance({
    required this.id,
    required this.userId,
    required this.eventId,
    required this.timestamp,
    required this.isPresent,
  });

  factory Attendance.fromJson(Map<String, dynamic> json, String docId) {
    return Attendance(
      id: docId,
      userId: json['userId'] ?? '',
      eventId: json['eventId'] ?? '',
      timestamp: (json['timestamp'] as Timestamp).toDate(),
      isPresent: json['isPresent'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'eventId': eventId,
      'timestamp': timestamp,
      'isPresent': isPresent,
    };
  }
}

// lib/models/team_model.dart

class Team {
  final String id;
  final String name;
  final String eventId;
  final List<String> memberIds;
  final String secretCode;

  Team({
    required this.id,
    required this.name,
    required this.eventId,
    required this.memberIds,
    required this.secretCode,
  });

  factory Team.fromJson(Map<String, dynamic> json, String docId) {
    return Team(
      id: docId,
      name: json['name'] ?? '',
      eventId: json['eventId'] ?? '',
      memberIds: List<String>.from(json['memberIds'] ?? []),
      secretCode: json['secretCode'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'eventId': eventId,
      'memberIds': memberIds,
      'secretCode': secretCode,
    };
  }
}

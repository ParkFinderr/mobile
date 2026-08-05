class ReservationTimestamps {
  final String? created;
  final String? arrived;
  final String? completed;

  ReservationTimestamps({
    this.created,
    this.arrived,
    this.completed,
  });

  factory ReservationTimestamps.fromJson(Map<String, dynamic> json) {
    return ReservationTimestamps(
      created: json['created'] as String? ??
          json['createdAt'] as String? ??
          json['created_at'] as String? ??
          json['startTime'] as String?,
      arrived: json['arrived'] as String? ??
          json['arrivedAt'] as String? ??
          json['arrived_at'] as String?,
      completed: json['completed'] as String? ??
          json['completedAt'] as String? ??
          json['completed_at'] as String?,
    );
  }
}

class ReservationHistory {
  final String reservationId;
  final String ticketId;
  final String userId;
  final String slotId;
  final String areaId;
  final String slotName;
  final String name;
  final String plateNumber;
  final String status;
  final ReservationTimestamps timestamps;
  final List<dynamic> history;
  final String formattedDuration;

  ReservationHistory({
    required this.reservationId,
    required this.ticketId,
    required this.userId,
    required this.slotId,
    required this.areaId,
    required this.slotName,
    required this.name,
    required this.plateNumber,
    required this.status,
    required this.timestamps,
    required this.history,
    required this.formattedDuration,
  });

  factory ReservationHistory.fromJson(Map<String, dynamic> json) {
    final timestampsJson = (json['timestamps'] is Map)
        ? json['timestamps'] as Map<String, dynamic>
        : <String, dynamic>{
            'created': json['created'] ??
                json['createdAt'] ??
                json['created_at'] ??
                json['startTime'],
            'arrived': json['arrived'] ?? json['arrivedAt'] ?? json['arrived_at'],
            'completed':
                json['completed'] ?? json['completedAt'] ?? json['completed_at'],
          };

    final slotObj =
        json['slot'] is Map ? json['slot'] as Map<String, dynamic> : null;
    final areaObj =
        json['area'] is Map ? json['area'] as Map<String, dynamic> : null;

    final parsedSlotName = json['slotName'] as String? ??
        json['slotNumber'] as String? ??
        json['slot'] as String? ??
        slotObj?['slotNumber'] as String? ??
        slotObj?['label'] as String? ??
        slotObj?['name'] as String? ??
        '';

    final parsedAreaId = json['areaId'] as String? ??
        areaObj?['id'] as String? ??
        areaObj?['_id'] as String? ??
        '';

    return ReservationHistory(
      reservationId: json['reservationId'] as String? ??
          json['id'] as String? ??
          json['_id'] as String? ??
          '',
      ticketId: json['ticketId'] as String? ??
          json['ticketCode'] as String? ??
          json['ticket'] as String? ??
          '',
      userId: json['userId'] as String? ?? json['user'] as String? ?? '',
      slotId: json['slotId'] as String? ??
          slotObj?['id'] as String? ??
          slotObj?['_id'] as String? ??
          '',
      areaId: parsedAreaId,
      slotName: parsedSlotName,
      name: json['name'] as String? ?? '',
      plateNumber: json['plateNumber'] as String? ?? '',
      status: json['status'] as String? ?? '',
      timestamps: ReservationTimestamps.fromJson(timestampsJson),
      history: (json['history'] is List) ? json['history'] as List<dynamic> : [],
      formattedDuration: json['formattedDuration'] as String? ?? '-',
    );
  }
}

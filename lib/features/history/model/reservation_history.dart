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
      created: json['created'],
      arrived: json['arrived'],
      completed: json['completed'],
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
    return ReservationHistory(
      reservationId: json['reservationId'] ?? '',
      ticketId: json['ticketId'] ?? '',
      userId: json['userId'] ?? '',
      slotId: json['slotId'] ?? '',
      areaId: json['areaId'] ?? '',
      slotName: json['slotName'] ?? '',
      name: json['name'] ?? '',
      plateNumber: json['plateNumber'] ?? '',
      status: json['status'] ?? '',
      timestamps: ReservationTimestamps.fromJson(json['timestamps'] ?? {}),
      history: json['history'] ?? [],
      formattedDuration: json['formattedDuration'] ?? '-',
    );
  }
}

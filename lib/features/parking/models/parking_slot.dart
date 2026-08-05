/// ParkingSlot — Model slot parkir dari API GET /areas/{id}/slots.
class ParkingSlot {
  final String id;
  final String slotNumber;
  final String status;
  final String vehicleType;

  const ParkingSlot({
    required this.id,
    required this.slotNumber,
    required this.status,
    required this.vehicleType,
  });

  factory ParkingSlot.fromJson(Map<String, dynamic> json) {
    return ParkingSlot(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      slotNumber:
          json['slotName'] as String? ?? json['slotNumber'] as String? ?? '',
      status: json['appStatus'] as String? ??
          json['status'] as String? ??
          'available',
      vehicleType: json['vehicleType'] as String? ?? 'mobil',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'slotName': slotNumber,
        'status': status,
        'vehicleType': vehicleType,
      };

  /// Apakah slot tersedia untuk booking
  bool get isAvailable => status == 'available';

  /// Apakah slot sedang digunakan
  bool get isOccupied => status == 'occupied' || status == 'reserved';
}

/// ParkingArea — Model area parkir dari API GET /areas.
class ParkingArea {
  final String id;
  final String name;
  final String address;
  final int totalSlot;
  final int availableSlots;

  const ParkingArea({
    required this.id,
    required this.name,
    required this.address,
    required this.totalSlot,
    required this.availableSlots,
  });

  factory ParkingArea.fromJson(Map<String, dynamic> json) {
    return ParkingArea(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown Area',
      address: json['address'] as String? ??
          json['location'] as String? ??
          'Unknown Location',
      totalSlot:
          (json['totalSlots'] ?? json['totalSlot'] ?? json['slot'] ?? 0) as int,
      availableSlots:
          (json['availableSlots'] ?? json['availableSlot'] ?? 0) as int,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'address': address,
        'totalSlots': totalSlot,
        'availableSlots': availableSlots,
      };

  /// Persentase ketersediaan slot (0.0 - 1.0)
  double get availabilityRatio =>
      totalSlot > 0 ? availableSlots / totalSlot : 0;

  /// Apakah masih ada slot tersedia
  bool get hasAvailableSlot => availableSlots > 0;
}

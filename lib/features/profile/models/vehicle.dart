/// Vehicle — Model kendaraan pengguna dari GET /users/vehicles.
///
/// Field didasarkan pada response aktual backend.
/// Backend TIDAK mengembalikan field `id` — kendaraan diidentifikasi via plateNumber.
class Vehicle {
  final String plateNumber;
  final String vehicleType;

  const Vehicle({
    required this.plateNumber,
    required this.vehicleType,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) {
    return Vehicle(
      plateNumber: json['plateNumber']?.toString() ?? '',
      vehicleType: json['vehicleType']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'plateNumber': plateNumber,
        'vehicleType': vehicleType,
      };

  /// Jenis kendaraan yang dikapitalisasi untuk tampilan UI.
  String get displayType {
    if (vehicleType.isEmpty) return 'Kendaraan';
    return '${vehicleType[0].toUpperCase()}${vehicleType.substring(1)}';
  }

  @override
  String toString() => 'Vehicle(plate: $plateNumber, type: $vehicleType)';
}

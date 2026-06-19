/// Vehicle — Model kendaraan pengguna.
///
/// Field didasarkan pada response aktual GET /users/profile → data.vehicles.
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

  Map<String, dynamic> toJson() {
    return {
      'plateNumber': plateNumber,
      'vehicleType': vehicleType,
    };
  }

  @override
  String toString() => 'Vehicle(plate: $plateNumber, type: $vehicleType)';
}

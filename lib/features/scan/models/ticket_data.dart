/// TicketData — Model tiket parkir dari API POST /access/verify.
///
/// Dipisahkan dari scan_service.dart agar model bisa digunakan
/// oleh scan_service, access_service, active_ticket_storage, dan route.
class TicketData {
  final String ticketCode;
  final String status;
  final String vehicleType;
  final String areaId;
  final String areaName;
  final String bindingId;
  final String claimedAt;

  const TicketData({
    required this.ticketCode,
    required this.status,
    this.vehicleType = '',
    this.areaId = '',
    this.areaName = '',
    this.bindingId = '',
    this.claimedAt = '',
  });

  factory TicketData.fromJson(Map<String, dynamic> json) {
    return TicketData(
      ticketCode: json['ticketId'] as String? ??
          json['ticketCode'] as String? ??
          json['code'] as String? ??
          json['id'] as String? ??
          '',
      status: json['status'] as String? ?? '',
      vehicleType: json['vehicleType'] as String? ?? '',
      areaId: json['areaId'] as String? ?? '',
      areaName: json['areaName'] as String? ?? '',
      bindingId: json['bindingId'] as String? ?? '',
      claimedAt: json['claimedAt'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'ticketId': ticketCode,
        'id': ticketCode,
        'status': status,
        'vehicleType': vehicleType,
        'areaId': areaId,
        'areaName': areaName,
        'bindingId': bindingId,
        'claimedAt': claimedAt,
      };

  bool get isValid => ticketCode.isNotEmpty;

  /// Apakah tiket ini sedang aktif (belum digunakan / belum expired)
  bool get isActive => status == 'active' || status == 'claimed';
}

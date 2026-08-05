import 'package:flutter/material.dart';
import '../../../shared/styles/app_colors.dart';
import 'package:mobile_front/features/profile/models/vehicle.dart';
import 'package:mobile_front/features/profile/services/profile_service.dart';

class VehicleManagementPage extends StatefulWidget {
  const VehicleManagementPage({super.key});

  @override
  State<VehicleManagementPage> createState() => _VehicleManagementPageState();
}

class _VehicleManagementPageState extends State<VehicleManagementPage> {
  final VehicleService _service = VehicleService();

  List<Vehicle> _vehicles = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  Future<void> _loadVehicles() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final vehicles = await _service.getVehicles();
      if (mounted) {
        setState(() {
          _vehicles = vehicles;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage =
              'Gagal memuat data kendaraan. Periksa koneksi internet Anda.';
          _isLoading = false;
        });
      }
    }
  }

  void _showAddVehicleDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddVehicleBottomSheet(
        onAdd: _handleAddVehicle,
      ),
    );
  }

  Future<void> _handleAddVehicle(String plateNumber, String vehicleType) async {
    if (mounted) Navigator.pop(context);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 12),
              Text('Menambahkan kendaraan...'),
            ],
          ),
          duration: Duration(seconds: 30),
          backgroundColor: Color(0xFF2563EB),
        ),
      );
    }

    try {
      final result = await _service.addVehicle(
        plateNumber: plateNumber,
        vehicleType: 'mobil',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }

      if (result.success) {
        await _loadVehicles();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: const Color(0xFF10B981),
              duration: const Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: const Color(0xFFEF4444),
              duration: const Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: const Color(0xFFEF4444),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  Future<void> _confirmDeleteVehicle(Vehicle vehicle) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = AppColors.getCardBg(context);
    final textPrimary = AppColors.getTextPrimary(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Hapus Kendaraan?',
          style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Kendaraan berikut akan dihapus dari akun Anda:',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardBg2Dark : const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.directions_car_rounded,
                      color: Color(0xFF2563EB), size: 22),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicle.plateNumber,
                        style: TextStyle(
                          color: textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const Text(
                        'Mobil',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Hapus', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _handleDeleteVehicle(vehicle);
    }
  }

  Future<void> _handleDeleteVehicle(Vehicle vehicle) async {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Menghapus kendaraan...'),
          duration: Duration(seconds: 30),
          backgroundColor: Color(0xFF061E3D),
        ),
      );
    }

    try {
      final success = await _service.deleteVehicle(vehicle.plateNumber);

      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }

      if (success) {
        await _loadVehicles();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Kendaraan berhasil dihapus.'),
              backgroundColor: Color(0xFF10B981),
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal menghapus kendaraan. Coba lagi.'),
              backgroundColor: Color(0xFFEF4444),
              duration: Duration(seconds: 4),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: const Color(0xFFEF4444),
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldBg = AppColors.getBackgroundColor(context);
    final textPrimary = AppColors.getTextPrimary(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.cardBgDark : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                            color: isDark
                                ? AppColors.borderColorDark
                                : const Color(0xFFE2E8F0)),
                      ),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: textPrimary,
                        size: 18,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Kendaraan Saya (Mobil)',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _showAddVehicleDialog,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Color(0xFF2563EB),
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(child: _buildBody(isDark, textPrimary)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(bool isDark, Color textPrimary) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(_errorMessage!, style: TextStyle(color: textPrimary)),
      );
    }

    if (_vehicles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.directions_car_outlined,
                size: 64, color: Color(0xFF94A3B8)),
            const SizedBox(height: 16),
            Text(
              'Belum ada kendaraan mobil terdaftar.',
              style: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _showAddVehicleDialog,
              icon: const Icon(Icons.add),
              label: const Text('Tambah Mobil'),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _vehicles.length,
      itemBuilder: (_, index) {
        final vehicle = _vehicles[index];
        final cardBg = AppColors.getCardBg(context);

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark
                  ? AppColors.borderColorDark
                  : const Color(0xFFE2E8F0),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: const BoxDecoration(
                  color: Color(0xFFDBEAFE),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.directions_car_rounded,
                    color: Color(0xFF1D4ED8), size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle.plateNumber,
                      style: TextStyle(
                        color: textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Mobil',
                      style: TextStyle(
                        color: Color(0xFF64748B),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _confirmDeleteVehicle(vehicle),
                icon: const Icon(Icons.delete_outline, color: Color(0xFFEF4444)),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AddVehicleBottomSheet extends StatefulWidget {
  final Future<void> Function(String plateNumber, String vehicleType) onAdd;

  const _AddVehicleBottomSheet({required this.onAdd});

  @override
  State<_AddVehicleBottomSheet> createState() => _AddVehicleBottomSheetState();
}

class _AddVehicleBottomSheetState extends State<_AddVehicleBottomSheet> {
  final _plateCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _plateCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await widget.onAdd(_plateCtrl.text.trim().toUpperCase(), 'mobil');
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = AppColors.getCardBg(context);
    final textPrimary = AppColors.getTextPrimary(context);

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Tambah Kendaraan Mobil',
              style: TextStyle(
                color: textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Masukkan plat nomor kendaraan mobil Anda.',
              style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
            ),
            const SizedBox(height: 20),

            Text(
              'Plat Nomor Mobil *',
              style: TextStyle(
                  color: isDark ? Colors.white70 : const Color(0xFF334155),
                  fontSize: 13,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _plateCtrl,
              textCapitalization: TextCapitalization.characters,
              style: TextStyle(
                color: textPrimary,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: 'Contoh: B 1234 CD',
                hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                filled: true,
                fillColor: isDark ? AppColors.cardBg2Dark : const Color(0xFFF8FAFC),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 14,
                  horizontal: 16,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: isDark
                        ? AppColors.borderColorDark
                        : const Color(0xFFE2E8F0),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF03192E), width: 1.5),
                ),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Plat nomor tidak boleh kosong.';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF03192E),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Simpan Mobil',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

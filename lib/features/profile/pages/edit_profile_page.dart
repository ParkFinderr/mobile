import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mobile_front/core/routes/app_routes.dart';
import '../../../shared/styles/app_colors.dart';
import 'package:mobile_front/features/profile/services/profile_service.dart';
import 'package:mobile_front/features/profile/models/vehicle.dart';

class EditProfilPage extends StatefulWidget {
  const EditProfilPage({super.key});

  @override
  State<EditProfilPage> createState() => _EditProfilPageState();
}

class _EditProfilPageState extends State<EditProfilPage> {
  final _namaCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _teleponCtrl = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;
  String? _photoUrl;
  List<Vehicle> _vehicles = [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profileService = ProfileService();
    final vehicleService = VehicleService();
    final profile = await profileService.getProfile();
    final vehicles = await vehicleService.getVehicles();
    if (mounted) {
      setState(() {
        _namaCtrl.text = profile?.name ?? '';
        _emailCtrl.text = profile?.email ?? '';
        _teleponCtrl.text = profile?.phoneNumber ?? '';
        _photoUrl = profile?.photoUrl;
        _vehicles = vehicles;
        _isLoading = false;
      });
    }
  }

  Future<void> _pickAndUploadPhoto() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );
      if (pickedFile == null) return;

      setState(() => _isSaving = true);

      final bytes = await pickedFile.readAsBytes();
      final name = pickedFile.name;

      final service = ProfileService();
      final result = await service.uploadPhoto(bytes: bytes, fileName: name);

      if (mounted) {
        setState(() => _isSaving = false);
        if (result.success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: const Color(0xFF10B981),
            ),
          );
          _loadProfile();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result.message),
              backgroundColor: const Color(0xFFEF4444),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih foto: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isSaving = true);
    final service = ProfileService();
    final result = await service.updateProfile(
      name: _namaCtrl.text.trim(),
      phoneNumber: _teleponCtrl.text.trim(),
    );
    if (mounted) {
      setState(() => _isSaving = false);
      if (result.success) {
        _showSuccess();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.message),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  InputDecoration _inputDeco(String label, bool isDark) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight, fontSize: 13),
      filled: true,
      fillColor: isDark ? AppColors.cardBg2Dark : const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: isDark ? AppColors.borderColorDark : const Color(0xFFE2E8F0),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF03192E), width: 1.5),
      ),
    );
  }

  void _showSuccess() {
    final cardBg = AppColors.getCardBg(context);
    final textPrimary = AppColors.getTextPrimary(context);

    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: cardBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                  color: Color(0xFF10B981),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 16),
              Text(
                'Profil Berhasil Diperbarui',
                style: TextStyle(
                    color: textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF03192E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('OK', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBg = AppColors.getBackgroundColor(context);
    final cardBg = AppColors.getCardBg(context);
    final cardBg2 = AppColors.getCardBg2(context);
    final textPrimary = AppColors.getTextPrimary(context);
    final textSecondary = AppColors.getTextSecondary(context);
    final borderColor = AppColors.getBorderColor(context);

    return Scaffold(
      backgroundColor: scaffoldBg,
      body: SafeArea(
        child: Column(
          children: [
            // App bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: borderColor),
                      ),
                      child: Icon(Icons.arrow_back_ios_new,
                          color: textPrimary, size: 18),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Edit Profil',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const SizedBox(height: 8),
                          // Avatar
                          GestureDetector(
                            onTap: _isSaving ? null : _pickAndUploadPhoto,
                            child: Stack(
                              children: [
                                Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    color: cardBg2,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        color: const Color(0xFF2563EB), width: 2),
                                  ),
                                  child: _photoUrl != null &&
                                          _photoUrl!.isNotEmpty
                                      ? ClipOval(
                                          child: CachedNetworkImage(
                                            imageUrl: _photoUrl!,
                                            fit: BoxFit.cover,
                                            placeholder: (context, url) =>
                                                const Center(
                                              child: SizedBox(
                                                width: 20,
                                                height: 20,
                                                child:
                                                    CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Color(0xFF2563EB),
                                                ),
                                              ),
                                            ),
                                            errorWidget:
                                                (context, url, error) =>
                                                    Icon(Icons.person,
                                                        color: textSecondary,
                                                        size: 54),
                                          ),
                                        )
                                      : Icon(Icons.person,
                                          color: textSecondary, size: 54),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          GestureDetector(
                            onTap: _isSaving ? null : _pickAndUploadPhoto,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: cardBg,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: borderColor),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.camera_alt_outlined,
                                      color: Color(0xFF2563EB), size: 14),
                                  SizedBox(width: 4),
                                  Text('Ubah Foto',
                                      style: TextStyle(
                                          color: Color(0xFF2563EB),
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Divider(color: borderColor),
                          const SizedBox(height: 16),

                          // Fields
                          _buildFieldLabel('Nama Lengkap*', textPrimary),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _namaCtrl,
                            style: TextStyle(color: textPrimary),
                            decoration: _inputDeco('Nama Lengkap', isDark),
                          ),
                          const SizedBox(height: 14),
                          _buildFieldLabel('Email (tidak dapat diubah)', textPrimary),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _emailCtrl,
                            readOnly: true,
                            style: TextStyle(color: textSecondary),
                            decoration: _inputDeco('Email', isDark).copyWith(
                              suffixIcon: Icon(
                                Icons.lock_outline,
                                color: textSecondary,
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          _buildFieldLabel('No Telp*', textPrimary),
                          const SizedBox(height: 6),
                          TextField(
                            controller: _teleponCtrl,
                            keyboardType: TextInputType.phone,
                            style: TextStyle(color: textPrimary),
                            decoration: _inputDeco('No. Telepon', isDark),
                          ),
                          const SizedBox(height: 20),

                          // Kendaraan section
                          GestureDetector(
                            onTap: () => Navigator.pushNamed(
                              context,
                              AppRoutes.vehicleManagement,
                            ).then((_) => _loadProfile()),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: cardBg2,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: borderColor),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.directions_car_outlined,
                                        color: Color(0xFF2563EB),
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Manajemen Kendaraan (Mobil)',
                                          style: TextStyle(
                                            color: textPrimary,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        color: textSecondary,
                                        size: 14,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    _vehicles.isEmpty
                                        ? 'Belum ada kendaraan. Ketuk untuk menambahkan.'
                                        : '${_vehicles.length} kendaraan mobil terdaftar: ${_vehicles.map((v) => v.plateNumber).join(', ')}',
                                    style: TextStyle(
                                      color: textSecondary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),

                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _saveProfile,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF03192E),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14)),
                              ),
                              child: _isSaving
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.5,
                                      ),
                                    )
                                  : const Text('Simpan Perubahan',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label, Color textPrimary) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(label,
          style: TextStyle(color: textPrimary, fontSize: 13, fontWeight: FontWeight.bold)),
    );
  }
}

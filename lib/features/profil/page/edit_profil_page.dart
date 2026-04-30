import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class EditProfilPage extends StatefulWidget {
  const EditProfilPage({super.key});

  @override
  State<EditProfilPage> createState() => _EditProfilPageState();
}

class _EditProfilPageState extends State<EditProfilPage> {
  final _namaCtrl = TextEditingController(text: 'Imam Ariadi');
  final _emailCtrl =
      TextEditingController(text: 'imamariadi775@gmail.com');
  final _teleponCtrl = TextEditingController(text: '085788322061');
  final _platCtrl = TextEditingController(text: 'D 12345 FE');
  final _merekCtrl = TextEditingController(text: 'Honda');
  final _modelCtrl = TextEditingController(text: 'Civic');

  InputDecoration _inputDeco(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle:
          const TextStyle(color: AppColors.textSecondary, fontSize: 12),
      filled: true,
      fillColor: AppColors.cardBg2,
      contentPadding:
          const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
      ),
    );
  }

  void _showSuccess() {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: const Color(0xFF1A2D47),
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
                  color: AppColors.green,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 40),
              ),
              const SizedBox(height: 16),
              const Text(
                'Profil Berhasil Diperbarui',
                style: TextStyle(
                    color: Colors.white,
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
                    backgroundColor: AppColors.cardBg,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('OK',
                      style: TextStyle(color: Colors.white)),
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
    return Scaffold(
      backgroundColor: AppColors.background,
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
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new,
                          color: Colors.white, size: 18),
                    ),
                  ),
                  const Expanded(
                    child: Text(
                      'Edit Profil',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 8),
                    // Avatar
                    Stack(
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            color: AppColors.cardBg2,
                            shape: BoxShape.circle,
                            border:
                                Border.all(color: AppColors.accent, width: 2),
                          ),
                          child: const Icon(Icons.person,
                              color: Colors.white70, size: 54),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: AppColors.borderColor),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.camera_alt_outlined,
                              color: AppColors.accent, size: 14),
                          SizedBox(width: 4),
                          Text('Ubah Foto',
                              style: TextStyle(
                                  color: AppColors.accent, fontSize: 12)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Divider(color: AppColors.borderColor),
                    const SizedBox(height: 16),

                    // Fields
                    _buildFieldLabel('Nama Lengkap*'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _namaCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDeco('Nama Lengkap'),
                    ),
                    const SizedBox(height: 14),
                    _buildFieldLabel('Email*'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _emailCtrl,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDeco('Email'),
                    ),
                    const SizedBox(height: 14),
                    _buildFieldLabel('No Telp*'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _teleponCtrl,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: Colors.white),
                      decoration: _inputDeco('No. Telepon'),
                    ),
                    const SizedBox(height: 20),

                    // Kendaraan utama section
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg2,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Kendaraan Utama',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Data kendaraan utama tidak dapat diubah. Hubungi admin jika perlu mengubah.',
                            style: TextStyle(
                                color: AppColors.textSecondary, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildFieldLabel('Plat Nomor*'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _platCtrl,
                      enabled: false,
                      style: const TextStyle(color: Colors.white54),
                      decoration: _inputDeco('Plat Nomor'),
                    ),
                    const SizedBox(height: 14),
                    _buildFieldLabel('Merek*'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _merekCtrl,
                      enabled: false,
                      style: const TextStyle(color: Colors.white54),
                      decoration: _inputDeco('Merek'),
                    ),
                    const SizedBox(height: 14),
                    _buildFieldLabel('Model*'),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _modelCtrl,
                      enabled: false,
                      style: const TextStyle(color: Colors.white54),
                      decoration: _inputDeco('Model'),
                    ),
                    const SizedBox(height: 20),

                    // Kendaraan Sekunder
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppColors.cardBg2,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Kendaraan Sekunder',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 13)),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: AppColors.accent,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text('+ Kendaraan',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 11)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Belum ada kendaraan sekunder. Klik\ntombol "Tambah Kendaraan" untuk\nmenambahkan.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _showSuccess,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.accent,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14)),
                        ),
                        child: const Text('Simpan Perubahan',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
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

  Widget _buildFieldLabel(String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(label,
          style: const TextStyle(color: Colors.white, fontSize: 13)),
    );
  }
}

import 'package:flutter/foundation.dart';
import '../models/profile_data.dart';
import '../models/vehicle.dart';
import '../services/profile_service.dart';

/// Enum state untuk operasi profil.
enum ProfileStatus { idle, loading, success, failure }

/// ProfileProvider — State management untuk fitur profil pengguna.
///
/// Mengelola:
/// - Data profil user (nama, email, foto)
/// - Daftar kendaraan
/// - Edit profil & upload foto
/// - CRUD kendaraan
///
/// Flow: UI → ProfileProvider → ProfileService/VehicleService → REST API
class ProfileProvider extends ChangeNotifier {
  final ProfileService _profileService;
  final VehicleService _vehicleService;

  ProfileProvider({
    ProfileService? profileService,
    VehicleService? vehicleService,
  })  : _profileService = profileService ?? ProfileService(),
        _vehicleService = vehicleService ?? VehicleService();

  // ─── State: Profil ────────────────────────────────────────────────────────
  ProfileData? _profile;
  ProfileStatus _profileStatus = ProfileStatus.idle;
  String? _profileError;

  ProfileData? get profile => _profile;
  ProfileStatus get profileStatus => _profileStatus;
  String? get profileError => _profileError;
  bool get isProfileLoading => _profileStatus == ProfileStatus.loading;
  bool get hasProfile => _profile != null;

  // ─── State: Kendaraan ─────────────────────────────────────────────────────
  List<Vehicle> _vehicles = [];
  ProfileStatus _vehiclesStatus = ProfileStatus.idle;

  List<Vehicle> get vehicles => _vehicles;
  ProfileStatus get vehiclesStatus => _vehiclesStatus;
  bool get isVehiclesLoading => _vehiclesStatus == ProfileStatus.loading;

  // ─── State: Update ────────────────────────────────────────────────────────
  ProfileStatus _updateStatus = ProfileStatus.idle;
  String? _updateMessage;

  ProfileStatus get updateStatus => _updateStatus;
  String? get updateMessage => _updateMessage;
  bool get isUpdating => _updateStatus == ProfileStatus.loading;

  // ─── Actions ──────────────────────────────────────────────────────────────

  Future<void> loadProfile() async {
    _profileStatus = ProfileStatus.loading;
    _profileError = null;
    notifyListeners();

    final result = await _profileService.getProfile();
    if (result != null) {
      _profile = result;
      _profileStatus = ProfileStatus.success;
    } else {
      _profileStatus = ProfileStatus.failure;
      _profileError = 'Gagal memuat profil. Periksa koneksi Anda.';
    }
    notifyListeners();
  }

  Future<void> loadVehicles() async {
    _vehiclesStatus = ProfileStatus.loading;
    notifyListeners();

    _vehicles = await _vehicleService.getVehicles();
    _vehiclesStatus = ProfileStatus.success;
    notifyListeners();
  }

  Future<UpdateProfileResult> updateProfile({
    required String name,
    required String phoneNumber,
  }) async {
    _updateStatus = ProfileStatus.loading;
    notifyListeners();

    final result = await _profileService.updateProfile(
      name: name,
      phoneNumber: phoneNumber,
    );

    _updateStatus =
        result.success ? ProfileStatus.success : ProfileStatus.failure;
    _updateMessage = result.message;

    if (result.success) {
      // Update local profile data
      if (_profile != null) {
        _profile = ProfileData(
          userId: _profile!.userId,
          name: name,
          email: _profile!.email,
          phoneNumber: phoneNumber,
          photoUrl: _profile!.photoUrl,
          role: _profile!.role,
        );
      }
    }

    notifyListeners();
    return result;
  }

  Future<UpdateProfileResult> uploadPhoto({
    required List<int> bytes,
    required String fileName,
  }) async {
    final result =
        await _profileService.uploadPhoto(bytes: bytes, fileName: fileName);
    if (result.success) {
      // Reload profil agar foto baru ter-update
      await loadProfile();
    }
    return result;
  }

  Future<AddVehicleResult> addVehicle({
    required String plateNumber,
    required String vehicleType,
  }) async {
    final result = await _vehicleService.addVehicle(
      plateNumber: plateNumber,
      vehicleType: vehicleType,
    );
    if (result.success) {
      await loadVehicles(); // Reload vehicles
    }
    return result;
  }

  Future<bool> deleteVehicle(String plateNumber) async {
    final success = await _vehicleService.deleteVehicle(plateNumber);
    if (success) {
      _vehicles.removeWhere((v) => v.plateNumber == plateNumber);
      notifyListeners();
    }
    return success;
  }

  void resetUpdateState() {
    _updateStatus = ProfileStatus.idle;
    _updateMessage = null;
    notifyListeners();
  }
}

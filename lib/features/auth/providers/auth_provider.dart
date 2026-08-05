import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../models/auth_result.dart';

/// Enum status state untuk Auth.
enum AuthStatus { idle, loading, success, failure }

/// AuthProvider — State management untuk fitur autentikasi.
///
/// Mengelola state login, register, dan logout.
/// Digunakan oleh LoginWidget, RegisterWidget melalui Provider.
///
/// Flow: UI → AuthProvider → AuthService → REST API
class AuthProvider extends ChangeNotifier {
  final AuthService _service;

  AuthProvider({AuthService? service}) : _service = service ?? AuthService();

  // ─── State ────────────────────────────────────────────────────────────────
  AuthStatus _loginStatus = AuthStatus.idle;
  AuthStatus _registerStatus = AuthStatus.idle;
  String? _errorMessage;
  bool _isLoggedIn = false;

  // ─── Getters ──────────────────────────────────────────────────────────────
  AuthStatus get loginStatus => _loginStatus;
  AuthStatus get registerStatus => _registerStatus;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoginLoading => _loginStatus == AuthStatus.loading;
  bool get isRegisterLoading => _registerStatus == AuthStatus.loading;

  // ─── Actions ──────────────────────────────────────────────────────────────

  /// Login dengan email dan password.
  Future<AuthResult> login(String email, String password) async {
    _loginStatus = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _service.login(email, password);

    if (result.isSuccess) {
      _loginStatus = AuthStatus.success;
      _isLoggedIn = true;
    } else {
      _loginStatus = AuthStatus.failure;
      _errorMessage = result.errorMessage;
    }
    notifyListeners();
    return result;
  }

  /// Register akun baru.
  Future<AuthResult> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String plateNumber,
  }) async {
    _registerStatus = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _service.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
      plateNumber: plateNumber,
    );

    if (result.isSuccess) {
      _registerStatus = AuthStatus.success;
    } else {
      _registerStatus = AuthStatus.failure;
      _errorMessage = result.errorMessage;
    }
    notifyListeners();
    return result;
  }

  /// Logout — hapus semua state dan data lokal.
  Future<void> logout() async {
    await _service.logout();
    _isLoggedIn = false;
    _loginStatus = AuthStatus.idle;
    _registerStatus = AuthStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }

  /// Cek status login saat app start.
  Future<void> checkLoginStatus() async {
    _isLoggedIn = await _service.isLoggedIn();
    notifyListeners();
  }

  /// Reset state ke idle (untuk clear error sebelum retry).
  void resetState() {
    _loginStatus = AuthStatus.idle;
    _registerStatus = AuthStatus.idle;
    _errorMessage = null;
    notifyListeners();
  }
}

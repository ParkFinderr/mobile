/// AuthResult — Model hasil operasi auth (login/register).
///
/// Digunakan oleh AuthService dan AuthProvider untuk komunikasi layer.
class AuthResult {
  /// true = berhasil, false = gagal
  final bool success;

  /// Pesan error jika gagal, null jika berhasil
  final String? errorMessage;

  const AuthResult.success()
      : success = true,
        errorMessage = null;
  const AuthResult.failure(this.errorMessage) : success = false;

  bool get isSuccess => success;
  bool get isFailure => !success;
}

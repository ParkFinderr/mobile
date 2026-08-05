/// ProfileData — Model data profil pengguna dari GET /users/profile.
class ProfileData {
  final String userId;
  final String name;
  final String email;
  final String phoneNumber;
  final String? photoUrl;
  final String role;

  const ProfileData({
    required this.userId,
    required this.name,
    required this.email,
    required this.phoneNumber,
    this.photoUrl,
    this.role = 'user',
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) {
    // Response dari GET /users/profile bisa langsung atau dibungkus {success, data: {...}}
    final Map<String, dynamic> src =
        (json['data'] is Map) ? json['data'] as Map<String, dynamic> : json;
    return ProfileData(
      userId: src['userId'] as String? ??
          src['id'] as String? ??
          src['_id'] as String? ??
          src['user_id'] as String? ??
          '',
      name: src['name'] as String? ?? 'User',
      email: src['email'] as String? ?? 'No Email',
      phoneNumber: src['phoneNumber'] as String? ??
          src['phone'] as String? ??
          'No Phone Number',
      photoUrl: src['photoUrl'] as String? ??
          src['photo'] as String? ??
          src['avatar'] as String?,
      role: src['role'] as String? ?? 'user',
    );
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        if (photoUrl != null) 'photoUrl': photoUrl,
        'role': role,
      };

  /// Inisial nama untuk avatar placeholder.
  String get initials {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }
}

/// UpdateProfileResult — Hasil dari operasi PUT /users/profile.
class UpdateProfileResult {
  final bool success;
  final String message;

  const UpdateProfileResult({required this.success, required this.message});
  const UpdateProfileResult.ok(this.message) : success = true;
  const UpdateProfileResult.failure(this.message) : success = false;
}

/// Data profil Admin.
///
/// Terpisah dari [UserProfile] agar role Admin tidak pernah tercampur dengan
/// user biasa. Untuk tahap ini seluruh isinya masih dummy; nanti begitu
/// backend siap, cukup ganti sumber datanya tanpa mengubah halaman.
class AdminProfile {
  const AdminProfile({
    required this.name,
    required this.role,
    required this.phone,
    required this.email,
    this.avatarAsset = 'assets/img/profil.jpg',
  });

  final String name;
  final String role;
  final String phone;
  final String email;
  final String avatarAsset;

  /// Inisial untuk avatar lingkaran pada header Beranda Admin.
  String get initial => name.isEmpty ? 'A' : name.substring(0, 1).toUpperCase();

  /// Salinan dengan sebagian field diganti, dipakai halaman Data Diri saat
  /// Admin menyimpan perubahan.
  AdminProfile copyWith({
    String? name,
    String? role,
    String? phone,
    String? email,
  }) => AdminProfile(
    name: name ?? this.name,
    role: role ?? this.role,
    phone: phone ?? this.phone,
    email: email ?? this.email,
    avatarAsset: avatarAsset,
  );
}

const AdminProfile dummyAdminProfile = AdminProfile(
  name: 'Admin',
  role: 'Administrator',
  phone: '0881 2345 6789',
  email: 'admin@pln.co.id',
);

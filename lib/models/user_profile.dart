/// Data pengguna yang sedang login.
///
/// Sekarang masih dummy/local. Structuranya dibuat terpisah supaya saat
/// backend siap, cukup ganti sumber datanya tanpa mengubah halaman.
class UserProfile {
  const UserProfile({
    required this.name,
    required this.status,
    required this.nip,
    required this.unit,
    required this.phone,
    required this.email,
    this.avatarAsset = 'assets/img/profil.jpg',
  });

  final String name;
  final String status;
  final String nip;
  final String unit;
  final String phone;
  final String email;
  final String avatarAsset;

  UserProfile copyWith({
    String? name,
    String? status,
    String? nip,
    String? unit,
    String? phone,
    String? email,
    String? avatarAsset,
  }) => UserProfile(
    name: name ?? this.name,
    status: status ?? this.status,
    nip: nip ?? this.nip,
    unit: unit ?? this.unit,
    phone: phone ?? this.phone,
    email: email ?? this.email,
    avatarAsset: avatarAsset ?? this.avatarAsset,
  );
}

/// Data dummy pengguna. Digunakan konsisten di Profil, Data Diri, dan
/// halaman lain yang membutuhkan data pengguna.
const UserProfile dummyUserProfile = UserProfile(
  name: 'Andi Pratama',
  status: 'Pegawai',
  nip: '1908125456709010',
  unit: 'UP3 Magelang',
  phone: '0881 2345 6789',
  email: 'andi.pratama@pln.co.id',
);

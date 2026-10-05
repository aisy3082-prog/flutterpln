import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../models/admin_profile.dart';
import '../../state/admin_auth_state.dart';
import '../../utils/constants.dart';
import '../../widgets/admin_header_actions.dart';
import '../../widgets/profile_group_row.dart';
import '../../widgets/detail_widgets.dart';

/// Halaman "Data Diri" untuk Admin.
///
/// Hanya baris "Data Diri" di halaman Profil yang membuka halaman ini.
/// Akses, Nomor HP, dan Email bisa diisi di sini, lalu disimpan ke
/// [AdminAuthState] supaya halaman Profil ikut menampilkan data terbaru.
class AdminPersonalDataPage extends StatefulWidget {
  const AdminPersonalDataPage({super.key, required this.profile});

  final AdminProfile profile;

  @override
  State<AdminPersonalDataPage> createState() => _AdminPersonalDataPageState();
}

class _AdminPersonalDataPageState extends State<AdminPersonalDataPage> {
  /// Field yang boleh diisi: Akses, Nomor HP, dan Email.
  late AdminProfile _profile = widget.profile;
  bool _isEditing = false;

  late final Map<String, TextEditingController> _controllers = {
    'role': TextEditingController(text: _profile.role),
    'phone': TextEditingController(text: _profile.phone),
    'email': TextEditingController(text: _profile.email),
  };

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  /// Simpan perubahan ke state, lalu kembali ke mode tampilan.
  void _save() {
    final auth = AdminAuthStateScope.maybeOf(context);
    final updated = _profile.copyWith(
      role: _text('role'),
      phone: _text('phone'),
      email: _text('email'),
    );

    setState(() {
      _profile = updated;
      _isEditing = false;
    });

    // Disimpan agar halaman Profil langsung ikut berubah.
    auth?.updateProfile(updated);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Perubahan data berhasil disimpan.')),
    );
  }

  /// Nilai dari controller, atau nilai lama kalau dikosongkan.
  String _text(String key) {
    final value = _controllers[key]!.text.trim();
    return value.isEmpty ? _profileValue(key) : value;
  }

  String _profileValue(String key) => switch (key) {
    'role' => _profile.role,
    'phone' => _profile.phone,
    _ => _profile.email,
  };

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
      // Kembalikan isi input ke nilai tersimpan saat mode edit dibatalkan.
      if (!_isEditing) {
        for (final entry in _controllers.entries) {
          entry.value.text = _profileValue(entry.key);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AdminPageAppBar(
          title: 'Data Diri',
          actions: [
            TextButton(
              onPressed: _toggleEdit,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                minimumSize: const Size(0, 32),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                _isEditing ? 'Batal' : 'Edit',
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              16,
              16,
              16,
              AppSpacing.pageBottom,
            ),
            children: [
              _IdentityCard(profile: _profile),
              const SizedBox(height: AppSpacing.xxl),
              ProfileGroupCard(
                children: [
                  // Nama tidak bisa diisi di tahap ini.
                  ProfileGroupRow(
                    icon: Icons.person_outline,
                    label: 'Nama',
                    value: _profile.name,
                  ),
                  ProfileGroupRow(
                    icon: Icons.badge_outlined,
                    label: 'Akses',
                    value: _profile.role,
                    controller: _controllers['role'],
                    editable: _isEditing,
                  ),
                  ProfileGroupRow(
                    icon: Icons.phone_outlined,
                    label: 'Nomor HP',
                    value: _profile.phone,
                    controller: _controllers['phone'],
                    editable: _isEditing,
                  ),
                  ProfileGroupRow(
                    icon: Icons.mail_outline,
                    label: 'Email',
                    value: _profile.email,
                    controller: _controllers['email'],
                    editable: _isEditing,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xxl),
              PrimaryActionButton(
                label: 'Simpan Perubahan',
                onPressed: _isEditing ? _save : _toggleEdit,
              ),
              const SizedBox(height: AppSpacing.md),
              const _AccessHint(),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kartu identitas: avatar, nama, dan role.
class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.profile});

  final AdminProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Row(
        children: [
          ClipOval(
            child: Image.asset(
              profile.avatarAsset,
              width: 54,
              height: 54,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
              errorBuilder: (context, _, _) => Container(
                width: 54,
                height: 54,
                color: AppColors.primarySoft,
                child: const Icon(Icons.person, color: AppColors.textSubtle),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xl),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  profile.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textStrong,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  profile.role,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 9,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Catatan bahwa akses Admin diatur lewat sistem.
class _AccessHint extends StatelessWidget {
  const _AccessHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.primarySoft.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 14, color: AppColors.primary),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Pastikan Akses, Nomor HP, dan Email terisi dengan benar karena '
              'dipakai pada laporan peminjaman.',
              style: TextStyle(
                color: AppColors.textMuted,
                fontSize: 9,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
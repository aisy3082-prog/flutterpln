import 'package:flutter/material.dart';

import '../models/user_profile.dart';
import '../state/auth_state.dart';
import '../utils/app_navigation.dart';
import '../utils/constants.dart';
import '../widgets/detail_widgets.dart';
import '../widgets/notification_detail_scaffold.dart';
import '../widgets/profile_menu_row.dart';

/// Halaman Data Diri: menampilkan informasi profil pengguna secara rapi.
///
/// Dipanggil dari baris "Data Diri" di halaman Profil. Unit Kerja, Nomor HP,
/// dan Email bisa diisi di sini, lalu disimpan ke [AuthState] supaya halaman
/// Profil ikut menampilkan data terbaru.
class PersonalDataPage extends StatefulWidget {
  const PersonalDataPage({super.key, required this.user});

  final UserProfile user;

  @override
  State<PersonalDataPage> createState() => _PersonalDataPageState();
}

class _PersonalDataPageState extends State<PersonalDataPage> {
  late UserProfile _user = widget.user;
  bool _isEditing = false;

  late final Map<String, TextEditingController> _controllers = {
    'name': TextEditingController(text: _user.name),
    'unit': TextEditingController(text: _user.unit),
    'phone': TextEditingController(text: _user.phone),
    'email': TextEditingController(text: _user.email),
  };

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _toggleEdit() {
    if (_isEditing) {
      // Field yang boleh diubah: nama, unit kerja, nomor HP, dan email.
      final updated = _user.copyWith(
        name: _text('name'),
        unit: _text('unit'),
        phone: _text('phone'),
        email: _text('email'),
      );

      setState(() {
        _user = updated;
        _isEditing = false;
      });

      // Disimpan agar halaman Profil langsung ikut berubah.
      AuthStateScope.maybeOf(context)?.updateUser(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perubahan data berhasil disimpan.')),
      );
      return;
    }
    setState(() {
      _isEditing = true;
    });
  }

  /// Nilai dari controller, atau nilai lama kalau dikosongkan.
  String _text(String key) {
    final value = _controllers[key]!.text.trim();
    return value.isEmpty ? _saved(key) : value;
  }

  /// Nilai tersimpan untuk field tertentu.
  String _saved(String key) => switch (key) {
    'name' => _user.name,
    'unit' => _user.unit,
    'phone' => _user.phone,
    _ => _user.email,
  };

  @override
  Widget build(BuildContext context) {
    return NotificationDetailScaffold(
      title: 'Data Diri',
      selectedTab: AppTab.profil,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _PhotoCard(user: _user),
          const SizedBox(height: AppSpacing.xxl),
          ProfileMenuCard(
            children: [
              _Field(
                label: 'Nama Lengkap',
                value: _user.name,
                controller: _controllers['name'],
                editable: _isEditing,
                icon: Icons.person_outline,
              ),
              _Field(
                label: 'NIP',
                value: _user.nip,
                icon: Icons.badge_outlined,
                // NIP tidak bisa diubah pada tahap ini.
              ),
              _Field(
                label: 'Jabatan',
                value: _user.status,
                icon: Icons.work_outline,
              ),
              _Field(
                label: 'Unit Kerja',
                value: _user.unit,
                controller: _controllers['unit'],
                editable: _isEditing,
                icon: Icons.apartment_outlined,
              ),
              _Field(
                label: 'Nomor HP',
                value: _user.phone,
                controller: _controllers['phone'],
                editable: _isEditing,
                icon: Icons.phone_outlined,
              ),
              _Field(
                label: 'Email',
                value: _user.email,
                controller: _controllers['email'],
                editable: _isEditing,
                icon: Icons.mail_outline,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          PrimaryActionButton(
            label: _isEditing ? 'Simpan Perubahan' : 'Edit Data',
            onPressed: _toggleEdit,
          ),
        ],
      ),
    );
  }
}

class _PhotoCard extends StatelessWidget {
  const _PhotoCard({required this.user});

  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderSoft),
      ),
      child: Row(
        children: [
          ClipOval(
            child: Image.asset(
              user.avatarAsset,
              width: 56,
              height: 56,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
              errorBuilder: (context, _, _) => Container(
                width: 56,
                height: 56,
                color: AppColors.primarySoft,
                child: const Icon(Icons.person, color: AppColors.textSubtle),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.xxl),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textStrong,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${user.status} - ${user.unit}',
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

/// Baris data pada halaman Data Diri: ikon, label, dan nilai.
/// Saat mode edit, nilai diganti menjadi input untuk field yang bisa diubah.
class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.value,
    required this.icon,
    this.controller,
    this.editable = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final TextEditingController? controller;
  final bool editable;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.borderBlue),
      ),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: const BoxDecoration(
              color: AppColors.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 15, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.xl),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textStrong,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          if (editable)
            Expanded(
              flex: 2,
              child: TextField(
                controller: controller,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  color: AppColors.textStrong,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                decoration: const InputDecoration(
                  isDense: true,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            )
          else
            Expanded(
              flex: 2,
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
                style: const TextStyle(color: AppColors.textMuted, fontSize: 9),
              ),
            ),
        ],
      ),
    );
  }
}

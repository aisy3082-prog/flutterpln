import 'package:flutter/material.dart';

/// Gaya visual navbar.
///
/// Dipakai agar area user dan area Admin bisa memakai SATU komponen yang sama
/// tanpa mengubah tampilan masing-masing: navbar user tetap datar, navbar
/// Admin tetap berupa kartu melayang.
enum AppNavStyle {
  /// Datar dengan garis pemisah di atas. Dipakai area user.
  flat,

  /// Kartu melayang dengan shadow halus. Dipakai area Admin.
  elevated,
}

/// Satu item menu pada navbar.
///
/// [key] disimpan sebagai string supaya tiap area bisa memakai pola key
/// sendiri tanpa mengubah komponen ini. [badge] untuk penanda jumlah (mis.
/// notifikasi belum dibaca); 0 berarti tidak ada badge.
class AppNavItem {
  const AppNavItem({
    required this.key,
    required this.label,
    required this.icon,
    this.badge = 0,
  });

  final String key;
  final String label;
  final IconData icon;
  final int badge;
}

/// Bottom Navigation tunggal untuk seluruh aplikasi.
///
/// Semua metrik navbar (tinggi, ukuran icon, ukuran label, jarak ikon ke
/// label, warna aktif/tidak aktif, dan SafeArea) didefinisikan DI SATU TEMPAT
/// di sini, sehingga tidak mungkin ada halaman yang memakai navbar dengan
/// ukuran atau gaya berbeda. Area user dan Admin memakai widget yang sama,
/// hanya [style] dan daftar [items] yang berbeda.
class AppNavBar extends StatelessWidget {
  const AppNavBar({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    this.style = AppNavStyle.flat,
  });

  static const double kNavHeight = 62;
  static const double kIconSize = 21;
  static const double kLabelSize = 8;
  static const double kIconLabelGap = 2;

  static const Color kActiveColor = Color(0xFF0B75D1);
  static const Color kInactiveColor = Color(0xFF8A949E);
  static const Color kBorderColor = Color(0xFFE0E4E8);

  final List<AppNavItem> items;

  /// Index menu aktif. Menu lain otomatis tampil tidak aktif.
  final int selectedIndex;

  /// Dipanggil dengan index menu yang ditekan.
  final ValueChanged<int> onSelected;

  final AppNavStyle style;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: kBorderColor)),
        boxShadow: style == AppNavStyle.elevated
            ? const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 12,
                  offset: Offset(0, -2),
                ),
              ]
            : const [],
      ),
      // SafeArea menjaga baris tombol tetap di atas system navigation bar
      // Android tanpa mengubah tinggi navbar.
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: kNavHeight,
          child: Row(
            children: [
              for (var i = 0; i < items.length; i++)
                Expanded(
                  child: _NavButton(
                    key: ValueKey(items[i].key),
                    item: items[i],
                    selected: i == selectedIndex,
                    onTap: () => onSelected(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    super.key,
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final AppNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? AppNavBar.kActiveColor
        : AppNavBar.kInactiveColor;

    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          // Separuh baris dipakai icon dan setengahnya label, keduanya jadi
          // target tap yang sama besarnya.
          child: SizedBox.expand(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(item.icon, size: AppNavBar.kIconSize, color: color),
                    // Badge jumlah notifikasi belum dibaca.
                    if (item.badge > 0)
                      Positioned(
                        right: -7,
                        top: -5,
                        child: Container(
                          key: ValueKey('nav_badge_${item.key}'),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 1.5,
                          ),
                          constraints: const BoxConstraints(minWidth: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE53935),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            item.badge > 99 ? '99+' : '${item.badge}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 7,
                              height: 1.2,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppNavBar.kIconLabelGap),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    item.label,
                    maxLines: 1,
                    style: TextStyle(
                      color: color,
                      fontSize: AppNavBar.kLabelSize,
                      fontWeight: selected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Kategori bantuan beserta langkah-langkahnya.
class HelpArticle {
  const HelpArticle({
    required this.id,
    required this.title,
    required this.icon,
    required this.steps,
    this.tip,
  });

  final String id;
  final String title;
  final IconData icon;
  final List<String> steps;
  final String? tip;
}

const List<HelpArticle> helpArticles = [
  HelpArticle(
    id: 'help-apply',
    title: 'Cara Mengajukan Peminjaman',
    icon: Icons.assignment_outlined,
    steps: [
      'Buka menu Kendaraan lalu pilih kendaraan yang berstatus Tersedia.',
      'Kendaraan berstatus Digunakan atau Perawatan tidak dapat dipilih.',
      'Tekan tombol Ajukan Peminjaman pada banner di Beranda.',
      'Lengkapi tanggal pinjam, tanggal kembali, tujuan, jumlah penumpang, dan keperluan.',
      'Kirim pengajuan dan pantau statusnya pada halaman Antrean Saya.',
    ],
    tip:
        'Pastikan tanggal kembali diisi dengan benar agar pengajuan disetujui.',
  ),
  HelpArticle(
    id: 'help-status',
    title: 'Cara Melihat Status Peminjaman',
    icon: Icons.pending_actions_outlined,
    steps: [
      'Buka Beranda lalu bagian Aktivitas Saya.',
      'Pilih Pengajuan Aktif untuk melihat pengajuan yang sedang diproses.',
      'Baris progress menunjukkan tahap: Pengajuan, Antrean, Disetujui, Dalam Perjalanan, dan Selesai.',
      'Pilih Menunggu Persetujuan untuk melihat pengajuan yang menunggu approval.',
    ],
  ),
  HelpArticle(
    id: 'help-contact-driver',
    title: 'Cara Menghubungi Driver',
    icon: Icons.support_agent_outlined,
    steps: [
      'Buka halaman Antrean Saya.',
      'Pada bagian Driver, tekan tombol hubungi untuk membuka WhatsApp.',
      'Simpan nomor driver agar mudah dihubungi kembali.',
    ],
    tip: 'Hubungi driver bila terlalu lambat di lokasi penjemputan.',
  ),
  HelpArticle(
    id: 'help-complete-trip',
    title: 'Cara Menyelesaikan Perjalanan',
    icon: Icons.route_outlined,
    steps: [
      'Buka Perjalanan Aktif lalu tekan tombol Detail Perjalanan.',
      'Tekan Selesai Perjalanan ketika tiba di tujuan.',
      'Isi kilometer tempuh dan energi yang digunakan.',
      'Lanjutkan ke halaman input BBM atau Daya Listrik untuk menyimpan bukti pengisian.',
    ],
  ),
  HelpArticle(
    id: 'help-fuel',
    title: 'Cara Mengisi Data BBM',
    icon: Icons.local_gas_station_outlined,
    steps: [
      'Pada halaman Penyelesaian Perjalanan pilih BBM atau Daya Listrik.',
      'Pilih jenis BBM, lalu isi jumlah liter dan harga per liter.',
      'Total biaya dan kilometer kendaraan dihitung otomatis.',
      'Tekan Simpan untuk menyimpan riwayat pengisian.',
    ],
    tip: 'Kendaraan listrik memakai alur pengisian kWh, bukan liter BBM.',
  ),
];

/// Kontak bantuan. Nilai dummy dan mudah diganti nanti.
const String helpContactEmail = 'helpdesk@pln.co.id';
const String helpContactPhone = '0881 2345 6789';

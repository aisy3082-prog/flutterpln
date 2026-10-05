import 'package:flutter/material.dart';

import '../data/help_data.dart';
import '../utils/app_navigation.dart';
import '../utils/constants.dart';
import '../widgets/notification_detail_scaffold.dart';
import '../widgets/profile_menu_row.dart';

/// Halaman Bantuan: daftar kategori bantuan yang bisa ditekan.
class HelpPage extends StatelessWidget {
  const HelpPage({super.key, this.showBottomNav = true});

  /// Diisi false saat dibuka dari area Admin supaya navbar user tidak muncul.
  final bool showBottomNav;

  void _openArticle(BuildContext context, HelpArticle article) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => HelpArticlePage(article: article),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NotificationDetailScaffold(
      title: 'Bantuan',
      selectedTab: AppTab.profil,
      showBottomNav: showBottomNav,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Cara menggunakan aplikasi peminjaman kendaraan.',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
              height: 1.4,
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          ProfileMenuCard(
            children: [
              for (var i = 0; i < helpArticles.length; i++) ...[
                if (i > 0) const SizedBox(height: AppSpacing.md),
                ProfileMenuRow(
                  icon: helpArticles[i].icon,
                  label: helpArticles[i].title,
                  onTap: () => _openArticle(context, helpArticles[i]),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.xxl),
          ProfileMenuCard(
            children: [
              ProfileMenuRow(
                icon: Icons.mail_outline,
                label: 'Email Helpdesk',
                value: helpContactEmail,
                onTap: () => _showContact(context, helpContactEmail),
              ),
              ProfileMenuRow(
                icon: Icons.phone_outlined,
                label: 'Telepon Helpdesk',
                value: helpContactPhone,
                onTap: () => _showContact(context, helpContactPhone),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showContact(BuildContext context, String value) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$value (kontak dummy, belum aktif)')),
    );
  }
}

/// Halaman detail satu topik bantuan: judul, langkah-langkah, dan tips.
class HelpArticlePage extends StatelessWidget {
  const HelpArticlePage({super.key, required this.article});

  final HelpArticle article;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back, size: 20),
          tooltip: 'Kembali',
        ),
        title: Text(
          article.title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textStrong,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.xxl,
            AppSpacing.md,
            AppSpacing.xxl,
            AppSpacing.pageBottom,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < article.steps.length; i++) ...[
                _StepRow(index: i + 1, text: article.steps[i]),
                const SizedBox(height: AppSpacing.xl),
              ],
              if (article.tip != null) ...[
                const SizedBox(height: AppSpacing.md),
                _TipCard(text: article.tip!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _StepRow extends StatelessWidget {
  const _StepRow({required this.index, required this.text});

  final int index;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 22,
          height: 22,
          decoration: const BoxDecoration(
            color: AppColors.primarySoft,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: Text(
            '$index',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 9,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xl),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.textStrong,
              fontSize: 10,
              height: 1.45,
            ),
          ),
        ),
      ],
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadius.large),
        border: Border.all(color: AppColors.borderBlue),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb_outline,
            size: 16,
            color: AppColors.primary,
          ),
          const SizedBox(width: AppSpacing.xl),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: AppColors.textStrong,
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

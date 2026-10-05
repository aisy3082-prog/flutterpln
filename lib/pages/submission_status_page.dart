import 'package:flutter/material.dart';

import '../models/loan_request.dart';
import '../services/history_service.dart';
import '../utils/constants.dart';
import '../widgets/async_state_builder.dart';
import '../widgets/loan_request_card.dart';
import '../utils/app_navigation.dart';
import '../widgets/app_bottom_navigation.dart';

/// Halaman daftar pengajuan kendaraan.
///
/// Mengambil data dari [LoanRequestService] lalu merender empat kondisi:
/// loading, ada data, tidak ada data, dan error.
class SubmissionStatusPage extends StatefulWidget {
  const SubmissionStatusPage({
    super.key,
    this.service = const DummyLoanRequestService(),
  });

  final LoanRequestService service;

  @override
  State<SubmissionStatusPage> createState() => _SubmissionStatusPageState();
}

class _SubmissionStatusPageState extends State<SubmissionStatusPage> {
  late Future<DataResult<List<LoanRequest>>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.service.loadSubmissions();
  }

  void _reload() {
    setState(() {
      _future = widget.service.loadSubmissions();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.of(context).maybePop(),
          icon: const Icon(Icons.arrow_back, size: 20),
          tooltip: 'Kembali',
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pengajuan',
              style: TextStyle(
                color: AppColors.textStrong,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Lihat pengajuan kendaraan anda',
              style: TextStyle(color: AppColors.textSubtle, fontSize: 8),
            ),
          ],
        ),
      ),
      body: SafeArea(
        top: false,
        child: FutureBuilder<DataResult<List<LoanRequest>>>(
          future: _future,
          builder: (context, snapshot) {
            final result = snapshot.connectionState == ConnectionState.done
                ? snapshot.data!
                : const DataResult<List<LoanRequest>>.loading();
            return AsyncStateBuilder<List<LoanRequest>>(
              result: result,
              onRetry: _reload,
              emptyTitle: 'Tidak ada pengajuan',
              emptyDescription:
                  'Saat ini Anda tidak memiliki pengajuan peminjaman kendaraan.',
              emptyIcon: Icons.description_outlined,
              wrapEmptyInCard: true,
              builder: (context, requests) {
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  itemCount: requests.length,
                  separatorBuilder: (context, index) =>
                      const SizedBox(height: AppSpacing.md),
                  itemBuilder: (context, index) {
                    return LoanRequestCard(request: requests[index]);
                  },
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: const AppBottomNavigation(
        selectedTab: AppTab.beranda,
      ),
    );
  }
}

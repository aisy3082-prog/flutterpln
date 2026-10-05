import 'package:url_launcher/url_launcher.dart';

import '../state/loan_state.dart';

Future<bool> openDriverWhatsApp() async {
  final uri = Uri.parse('https://wa.me/${LoanState.driver.phone}');

  try {
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  } catch (_) {
    return false;
  }
}

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../state/admin_auth_state.dart';
import '../../widgets/auth_widgets.dart';
import 'admin_navigation.dart';

/// Kredensial Admin sementara. Nanti diganti dengan pengecekan backend.
const String dummyAdminEmail = 'admin2@pln.co.id';
const String dummyAdminPassword = '12345678';

/// Halaman Login Admin.
///
/// Terpisah dari [LoginPage] milik user: kredensial, state, dan tujuan
/// setelah login semuanya berbeda sehingga role Admin tidak pernah tercampur
/// dengan user biasa.
class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key});

  @override
  State<AdminLoginPage> createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> {
  static const Color _primaryBlue = Color(0xFF0B75D1);

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _loginError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _loginError = null;
    });

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email != dummyAdminEmail || password != dummyAdminPassword) {
      setState(() {
        _loginError = 'Email atau password Admin salah.';
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    // Tanda session lokal sebagai login Admin.
    AdminAuthStateScope.maybeOf(context)?.signIn();

    if (!mounted) {
      return;
    }
    // Delay pendek supaya tombol "Login" sempat menampilkan status memproses.
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (!mounted) {
      return;
    }
    setState(() {
      _isSubmitting = false;
    });

    // Area Admin dibuka sebagai root, membuang login dari stack.
    openAdminAsRoot(context);
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Color(0xFF0B75D1),
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: Colors.white,
        resizeToAvoidBottomInset: true,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final horizontalPadding = constraints.maxWidth < 360
                  ? 16.0
                  : 20.0;
              final headerHeight = math.min(
                300.0,
                math.max(220.0, constraints.maxHeight * 0.38),
              );

              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: Column(
                    children: [
                      _AdminAuthHeader(height: headerHeight),
                      Transform.translate(
                        offset: const Offset(0, -20),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                          ),
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(18, 12, 18, 20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  const AuthCardHandle(),
                                  const SizedBox(height: 20),
                                  AuthTextField(
                                    controller: _emailController,
                                    hintText: 'Email Admin',
                                    icon: Icons.mail_outline,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    validator: (value) {
                                      if (value == null ||
                                          value.trim().isEmpty) {
                                        return 'Email wajib diisi';
                                      }
                                      if (!RegExp(
                                        r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                      ).hasMatch(value.trim())) {
                                        return 'Format email tidak valid';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  AuthTextField(
                                    controller: _passwordController,
                                    hintText: 'Password',
                                    icon: Icons.lock_outline,
                                    obscureText: _obscurePassword,
                                    textInputAction: TextInputAction.done,
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword =
                                              !_obscurePassword;
                                        });
                                      },
                                      icon: Icon(
                                        _obscurePassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        size: 18,
                                        color: const Color(0xFF7D8791),
                                      ),
                                      tooltip: _obscurePassword
                                          ? 'Tampilkan password'
                                          : 'Sembunyikan password',
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Password wajib diisi';
                                      }
                                      return null;
                                    },
                                    onFieldSubmitted: (_) => _submit(),
                                  ),
                                  const SizedBox(height: 14),
                                  if (_loginError != null) ...[
                                    Text(
                                      _loginError!,
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
                                        color: Color(0xFFD9534F),
                                        fontSize: 9,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                  ],
                                  SizedBox(
                                    width: double.infinity,
                                    height: 42,
                                    child: ElevatedButton(
                                      onPressed: _isSubmitting
                                          ? null
                                          : _submit,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _primaryBlue,
                                        foregroundColor: Colors.white,
                                        disabledBackgroundColor: const Color(
                                          0xFF9EC3E6,
                                        ),
                                        elevation: 0,
                                        padding: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        textStyle: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      child: _isSubmitting
                                          ? const SizedBox(
                                              width: 16,
                                              height: 16,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                                color: Colors.white,
                                              ),
                                            )
                                          : const Text('Login'),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Header login Admin: gambar yang sama dengan login user, tetapi judulnya
/// menjelaskan bahwa ini area Administrator.
class _AdminAuthHeader extends StatelessWidget {
  const _AdminAuthHeader({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const AuthBackground(),
          const ColoredBox(color: Color(0x66000000)),
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Login Admin',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Kelola peminjaman kendaraan PLN',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontSize: 10,
                    height: 1.2,
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

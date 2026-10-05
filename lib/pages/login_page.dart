import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../state/auth_state.dart';
import '../utils/app_navigation.dart';
import '../widgets/auth_widgets.dart';
import 'admin/admin_login_page.dart';
import 'register_page.dart';

const String dummyEmail = 'admin@pln.co.id';
const String dummyPassword = '12345678';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  static const Color _primaryBlue = Color(0xFF0B75D1);
  static const Color _outline = Color(0xFFDCE1E6);
  static const Color _brandBlue = Color(0xFF0057A8);

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  String? _loginError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    setState(() {
      _loginError = null;
    });

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email != dummyEmail || password != dummyPassword) {
      FocusManager.instance.primaryFocus?.unfocus();
      setState(() {
        _loginError = 'Email atau password salah.';
      });
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    // Tandai session lokal sebagai login (pagingan tidak berubah).
    AuthStateScope.maybeOf(context)?.signIn();
    // Aplikasi dibuka dari shell (Beranda) sebagai root.
    openAppAsRoot(context);
  }

  void _openRegister() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const RegisterPage()));
  }

  /// Membuka halaman Login Admin. Area Admin punya alur dan kredensial
  /// sendiri, terpisah dari login user ini.
  void _openAdminLogin() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const AdminLoginPage()),
    );
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
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Column(
                    children: [
                      AuthHeader(height: headerHeight),
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
                                    hintText: 'Email',
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
                                          _obscurePassword = !_obscurePassword;
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
                                      onPressed: _submit,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _primaryBlue,
                                        foregroundColor: Colors.white,
                                        elevation: 0,
                                        padding: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        textStyle: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      child: const Text('Login'),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 42,
                                    child: OutlinedButton(
                                      onPressed: _openRegister,
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: _primaryBlue,
                                        side: const BorderSide(color: _outline),
                                        padding: EdgeInsets.zero,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        textStyle: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      child: const Text('Register'),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: _openRegister,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      child: Text.rich(
                                        const TextSpan(
                                          text: 'Belum Punya Akun? ',
                                          style: TextStyle(
                                            color: Color(0xFF0B75D1),
                                            fontSize: 8,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: 'Register Now',
                                              style: TextStyle(
                                                color: Color(0xFFE60000),
                                                fontSize: 8,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ],
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'PT PLN (Persero)',
                        style: TextStyle(
                          color: _brandBlue,
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Pintu masuk area Admin, terpisah dari login user.
                      TextButton(
                        onPressed: _openAdminLogin,
                        style: TextButton.styleFrom(
                          foregroundColor: _primaryBlue,
                          minimumSize: const Size(0, 34),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(9),
                            side: const BorderSide(color: _outline),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text('Masuk sebagai Admin'),
                      ),
                      const SizedBox(height: 8),
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

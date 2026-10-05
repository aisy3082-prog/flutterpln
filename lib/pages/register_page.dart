import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../widgets/auth_widgets.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key, this.onLoginRequested});

  final VoidCallback? onLoginRequested;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  static const Color _primaryBlue = Color(0xFF0B75D1);
  static const Color _brandBlue = Color(0xFF0057A8);

  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _goToLogin() {
    if (widget.onLoginRequested != null) {
      widget.onLoginRequested!();
      return;
    }

    Navigator.of(context).pop();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();
    _goToLogin();
  }

  String? _validateRequired(String? value, String message) {
    if (value == null || value.trim().isEmpty) {
      return message;
    }
    return null;
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
                260.0,
                math.max(200.0, constraints.maxHeight * 0.32),
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
                                    controller: _usernameController,
                                    hintText: 'Username',
                                    icon: Icons.person_outline,
                                    textInputAction: TextInputAction.next,
                                    validator: (value) => _validateRequired(
                                      value,
                                      'Username wajib diisi',
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  AuthTextField(
                                    controller: _emailController,
                                    hintText: 'Email',
                                    icon: Icons.mail_outline,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    validator: (value) {
                                      final required = _validateRequired(
                                        value,
                                        'Email wajib diisi',
                                      );
                                      if (required != null) {
                                        return required;
                                      }
                                      if (!RegExp(
                                        r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                                      ).hasMatch(value!.trim())) {
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
                                    textInputAction: TextInputAction.next,
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
                                    validator: (value) => _validateRequired(
                                      value,
                                      'Password wajib diisi',
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  AuthTextField(
                                    controller: _confirmPasswordController,
                                    hintText: 'Confirm Password',
                                    icon: Icons.lock_outline,
                                    obscureText: _obscureConfirmPassword,
                                    textInputAction: TextInputAction.done,
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          _obscureConfirmPassword =
                                              !_obscureConfirmPassword;
                                        });
                                      },
                                      icon: Icon(
                                        _obscureConfirmPassword
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                        size: 18,
                                        color: const Color(0xFF7D8791),
                                      ),
                                      tooltip: _obscureConfirmPassword
                                          ? 'Tampilkan password'
                                          : 'Sembunyikan password',
                                    ),
                                    validator: (value) {
                                      final required = _validateRequired(
                                        value,
                                        'Konfirmasi password wajib diisi',
                                      );
                                      if (required != null) {
                                        return required;
                                      }
                                      if (value != _passwordController.text) {
                                        return 'Password tidak sama';
                                      }
                                      return null;
                                    },
                                    onFieldSubmitted: (_) => _submit(),
                                  ),
                                  const SizedBox(height: 14),
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
                                      child: const Text('Register'),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  GestureDetector(
                                    behavior: HitTestBehavior.opaque,
                                    onTap: _goToLogin,
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 10,
                                      ),
                                      child: Text.rich(
                                        const TextSpan(
                                          text: 'Sudah Punya Akun? ',
                                          style: TextStyle(
                                            color: Color(0xFF0B75D1),
                                            fontSize: 8,
                                          ),
                                          children: [
                                            TextSpan(
                                              text: 'Login Now',
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

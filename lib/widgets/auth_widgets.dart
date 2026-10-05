import 'package:flutter/material.dart';

/// Foto latar halaman auth (gedung PLN).
///
/// Kalau asset-nya gagal terbaca, tetap tampilkan gradien brand supaya
/// halaman tidak berubah jadi kotak merah "Unable to load asset".
class AuthBackground extends StatelessWidget {
  const AuthBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/img/backgrond.jpeg',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0057A8), Color(0xFF0B75D1)],
          ),
        ),
      ),
    );
  }
}

class AuthHeader extends StatelessWidget {
  const AuthHeader({super.key, required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        fit: StackFit.expand,
        children: [
          const AuthBackground(),
          ColoredBox(color: const Color(0x66000000)),
          Positioned(
            left: 20,
            right: 20,
            bottom: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selamat Datang di\n'
                  'Aplikasi Peminjaman Kendaraan Dinas\n'
                  '& Pengelolaan BBM PLN',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Mudah, Cepat, dan Transparan',
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

class AuthTextField extends StatelessWidget {
  const AuthTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.icon,
    this.keyboardType,
    this.textInputAction,
    this.obscureText = false,
    this.suffixIcon,
    this.validator,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final Widget? suffixIcon;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      autocorrect: false,
      style: const TextStyle(color: Color(0xFF2E3742), fontSize: 11),
      cursorColor: const Color(0xFF0B75D1),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Color(0xFF8A949E), fontSize: 11),
        prefixIcon: SizedBox(
          width: 40,
          child: Icon(icon, size: 17, color: const Color(0xFF7D8791)),
        ),
        suffixIcon: suffixIcon,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 10,
          vertical: 12,
        ),
        filled: true,
        fillColor: Colors.white,
        border: _inputBorder(const Color(0xFFDCE1E6)),
        enabledBorder: _inputBorder(const Color(0xFFDCE1E6)),
        focusedBorder: _inputBorder(const Color(0xFF0B75D1)),
        errorBorder: _inputBorder(const Color(0xFFD9534F)),
        focusedErrorBorder: _inputBorder(const Color(0xFFD9534F)),
        errorStyle: const TextStyle(color: Color(0xFFD9534F), fontSize: 9),
        errorMaxLines: 2,
      ),
    );
  }
}

InputBorder _inputBorder(Color color) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(10),
    borderSide: BorderSide(color: color),
  );
}

class AuthCardHandle extends StatelessWidget {
  const AuthCardHandle({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: Container(
        width: 36,
        height: 3,
        decoration: BoxDecoration(
          color: const Color(0xFF7D8791),
          borderRadius: BorderRadius.circular(3),
        ),
      ),
    );
  }
}

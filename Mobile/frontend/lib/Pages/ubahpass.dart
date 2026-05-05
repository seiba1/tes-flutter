import 'package:flutter/material.dart';
import '../Service/serviceapi.dart';
import './ss_them.dart';
import 'login.dart';

class ForgotResetPage extends StatefulWidget {
  final String email;
  final String otp;
  const ForgotResetPage({super.key, required this.email, required this.otp});
  @override
  State<ForgotResetPage> createState() => _ForgotResetPageState();
}

class _ForgotResetPageState extends State<ForgotResetPage> {
  final _pass1 = TextEditingController();
  final _pass2 = TextEditingController();
  bool _loading = false;
  bool _show1 = false;
  bool _show2 = false;
  String _error = "";

  bool get _match => _pass2.text.isNotEmpty && _pass1.text == _pass2.text;
  bool get _noMatch => _pass2.text.isNotEmpty && _pass1.text != _pass2.text;

  @override
  void dispose() {
    _pass1.dispose();
    _pass2.dispose();
    super.dispose();
  }

  void _reset() async {
    setState(() => _error = "");
    if (_pass1.text.isEmpty || _pass2.text.isEmpty) {
      setState(() => _error = "Semua field wajib diisi");
      return;
    }
    if (_pass1.text != _pass2.text) {
      setState(() => _error = "Konfirmasi password tidak cocok");
      return;
    }
    if (_pass1.text.length < 8) {
      setState(() => _error = "Password minimal 8 karakter");
      return;
    }

    setState(() => _loading = true);
    final res = await ServiceApi.resetPassword(
        widget.email, widget.otp, _pass1.text);
    if (!mounted) return;
    setState(() => _loading = false);

    if (res['status'] == 'success') {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) => AlertDialog(
          backgroundColor: ssWhite,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: const BoxDecoration(
                    color: Color(0xffF0FDF4), shape: BoxShape.circle),
                child: const Icon(Icons.check_circle_rounded,
                    color: ssGreen, size: 40),
              ),
              const SizedBox(height: 16),
              const Text(
                "Password Berhasil\nDiubah!",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: ssGray800),
              ),
              const SizedBox(height: 8),
              const Text(
                "Silakan login kembali dengan password baru kamu.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13, color: ssGray500, height: 1.5),
              ),
              const SizedBox(height: 20),
              SSButton(
                label: "Login Sekarang",
                isLoading: false,
                onPressed: () => Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginPage()),
                  (r) => false,
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      setState(
          () => _error = res['message'] ?? "Gagal mengubah password");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: bgGradient,
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 440),
                padding:
                    const EdgeInsets.fromLTRB(40, 44, 40, 36),
                decoration: BoxDecoration(
                  color: ssWhite,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [
                    BoxShadow(
                        color: Color(0x242563EB),
                        blurRadius: 60,
                        offset: Offset(0, 20)),
                    BoxShadow(
                        color: Color(0x0F000000),
                        blurRadius: 16,
                        offset: Offset(0, 4)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SSStepIndicator(current: 3),
                    const SizedBox(height: 28),

                    // Icon
                    Container(
                      width: 68,
                      height: 68,
                      decoration: const BoxDecoration(
                          color: Color(0xffF0FDF4),
                          shape: BoxShape.circle),
                      child: const Icon(Icons.shield_outlined,
                          color: ssGreen, size: 30),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      "Buat Password Baru",
                      style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: ssGray800),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Buat password baru yang kuat dan mudah kamu ingat.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 13.5,
                          color: ssGray500,
                          height: 1.6),
                    ),
                    const SizedBox(height: 28),

                    // Password baru
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Password Baru",
                          style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: ssGray600)),
                    ),
                    const SizedBox(height: 5),
                    TextField(
                      controller: _pass1,
                      obscureText: !_show1,
                      style: const TextStyle(
                          color: ssGray800, fontSize: 14),
                      onChanged: (_) => setState(() {}),
                      decoration: ssInput(
                        hint: "Minimal 8 karakter",
                        prefix: const Icon(Icons.lock_outline,
                            color: ssGray400, size: 18),
                        suffix: IconButton(
                          icon: Icon(
                              _show1
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: ssGray400,
                              size: 20),
                          onPressed: () =>
                              setState(() => _show1 = !_show1),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Konfirmasi password
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text("Konfirmasi Password",
                          style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w600,
                              color: ssGray600)),
                    ),
                    const SizedBox(height: 5),
                    TextField(
                      controller: _pass2,
                      obscureText: !_show2,
                      style: const TextStyle(
                          color: ssGray800, fontSize: 14),
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: "Ulangi password baru",
                        hintStyle: const TextStyle(
                            color: ssGray300, fontSize: 14),
                        filled: true,
                        fillColor: _match
                            ? const Color(0xffF0FDF4)
                            : _noMatch
                                ? const Color(0xffFEF2F2)
                                : ssGray50,
                        prefixIcon: const Icon(
                            Icons.shield_outlined,
                            color: ssGray400,
                            size: 18),
                        suffixIcon: IconButton(
                          icon: Icon(
                              _show2
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: ssGray400,
                              size: 20),
                          onPressed: () =>
                              setState(() => _show2 = !_show2),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 13),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: _match
                                ? ssGreen
                                : _noMatch
                                    ? ssRed
                                    : ssGray200,
                            width: 1.8,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color: _match ? ssGreen : ssBlue500,
                            width: 1.8,
                          ),
                        ),
                      ),
                    ),

                    if (_match)
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("✓ Password cocok",
                              style: TextStyle(
                                  color: ssGreen,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                    if (_noMatch)
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text("✗ Password tidak cocok",
                              style: TextStyle(
                                  color: ssRed,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),

                    SSError(message: _error),
                    const SizedBox(height: 22),

                    // Tombol hijau
                    SSButton(
                      label: "Simpan Password Baru",
                      isLoading: _loading,
                      onPressed: _match ? _reset : null,
                      colors: const [ssGreen, ssGreenD],
                    ),
                    const SizedBox(height: 16),

                    GestureDetector(
                      onTap: () => Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginPage()),
                          (r) => false),
                      child: const Text(
                        "← Kembali ke Login",
                        style: TextStyle(
                            color: ssBlue600,
                            fontSize: 13,
                            fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
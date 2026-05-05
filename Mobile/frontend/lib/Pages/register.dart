import 'package:flutter/material.dart';
import '../Service/serviceapi.dart';
import './ss_them.dart';
import 'login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _username = TextEditingController();
  final _email    = TextEditingController();
  final _hp       = TextEditingController();
  final _pass     = TextEditingController();
  bool _loading = false;
  bool _showPass = false;
  String _error = "";

  @override
  void dispose() {
    _username.dispose(); _email.dispose();
    _hp.dispose(); _pass.dispose();
    super.dispose();
  }

  void _doRegister() async {
    setState(() => _error = "");
    if (_username.text.isEmpty || _email.text.isEmpty ||
        _hp.text.isEmpty || _pass.text.isEmpty) {
      setState(() => _error = "Semua field wajib diisi"); return;
    }
    if (_pass.text.length < 8) {
      setState(() => _error = "Password minimal 8 karakter"); return;
    }

    setState(() => _loading = true);
    final res = await ServiceApi.register({
      "username": _username.text.trim(),
      "email": _email.text.trim(),
      "no_hp": _hp.text.trim(),
      "password": _pass.text,
    });
    if (!mounted) return;
    setState(() => _loading = false);

    if (res['status'] == 'success') {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Registrasi berhasil! Silakan login."),
            backgroundColor: ssGreenD));
      Navigator.pop(context);
    } else {
      setState(() => _error = res['message'] ?? "Registrasi gagal");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: bgGradient,
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 420),
                padding: const EdgeInsets.all(36),
                decoration: BoxDecoration(
                  color: ssWhite,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [
                    BoxShadow(color: Color(0x2E2563EB),
                        blurRadius: 60, offset: Offset(0, 20)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Row(children: [
                        Icon(Icons.arrow_back_ios_rounded,
                            size: 14, color: ssBlue600),
                        Text("Kembali",
                            style: TextStyle(color: ssBlue600, fontSize: 13,
                                fontWeight: FontWeight.w600)),
                      ]),
                    ),
                    const SizedBox(height: 20),

                    const Text("Daftar Akun",
                        style: TextStyle(fontFamily: 'Nunito',
                            fontSize: 26, fontWeight: FontWeight.w900,
                            color: ssGray800)),
                    const SizedBox(height: 4),
                    const Text("Buat akun baru 🚀",
                        style: TextStyle(fontSize: 13.5, color: ssGray500)),
                    const SizedBox(height: 24),

                    _field("Nama", _username, "Nama lengkap"),
                    _field("Email", _email, "contoh@email.com",
                        type: TextInputType.emailAddress),
                    _field("No HP", _hp, "08xxxxxxxxxx",
                        type: TextInputType.phone),

                    _label("Password"),
                    const SizedBox(height: 5),
                    TextField(
                      controller: _pass,
                      obscureText: !_showPass,
                      style: const TextStyle(color: ssGray800, fontSize: 14),
                      decoration: ssInput(
                        hint: "Minimal 8 karakter",
                        suffix: IconButton(
                          icon: Icon(
                            _showPass ? Icons.visibility : Icons.visibility_off,
                            color: ssGray400, size: 20),
                          onPressed: () =>
                              setState(() => _showPass = !_showPass),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),

                    SSError(message: _error),
                    const SizedBox(height: 12),

                    SSButton(
                        label: "Daftar",
                        isLoading: _loading,
                        onPressed: _doRegister),
                    const SizedBox(height: 18),

                    Center(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 13, color: ssGray500),
                          children: [
                            const TextSpan(text: "Sudah punya akun? "),
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: () => Navigator.pushReplacement(context,
                                    MaterialPageRoute(
                                        builder: (_) => const LoginPage())),
                                child: const Text("Masuk",
                                    style: TextStyle(color: ssBlue600,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13)),
                              ),
                            ),
                          ],
                        ),
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

  Widget _field(String label, TextEditingController ctrl, String hint,
      {TextInputType? type}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _label(label),
      const SizedBox(height: 5),
      TextField(
        controller: ctrl,
        keyboardType: type,
        style: const TextStyle(color: ssGray800, fontSize: 14),
        decoration: ssInput(hint: hint),
      ),
      const SizedBox(height: 14),
    ]);
  }

  Widget _label(String text) => Text(text,
      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600,
          color: ssGray600, letterSpacing: 0.3));
}
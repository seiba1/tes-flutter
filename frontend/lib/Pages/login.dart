import 'package:flutter/material.dart';
import '../Service/serviceapi.dart';
import '../Service/biometric_service.dart'; // ✅ tambah
import './ss_them.dart';
import 'register.dart';
import 'home.dart';
import 'lupapass.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _email = TextEditingController();
  final _pass  = TextEditingController();
  bool _loading        = false;
  bool _showPass       = false;
  bool _biometricReady = false; // ✅ tambah
  String _error        = "";

  @override
  void initState() { // ✅ tambah
    super.initState();
    _cekBiometrik();
  }

  @override
  void dispose() { _email.dispose(); _pass.dispose(); super.dispose(); }

  // ✅ tambah fungsi cek biometrik
  Future<void> _cekBiometrik() async {
    final supported = await BiometricService.isSupported();
    final enabled   = await BiometricService.isEnabled();
    final loggedIn  = await ServiceApi.isLoggedIn();
    if (mounted) {
      setState(() => _biometricReady = supported && enabled && loggedIn);
      if (_biometricReady) _loginBiometrik();
    }
  }

  // ✅ tambah fungsi login biometrik
  Future<void> _loginBiometrik() async {
    final ok = await BiometricService.authenticate();
    if (!mounted) return;
    if (ok) Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (_) => const HomePage()));
  }

  // ✅ tambah dialog tawaran biometrik
  void _tawarkanBiometrik() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        backgroundColor: ssWhite,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 68, height: 68,
              decoration: const BoxDecoration(
                  color: Color(0xffEFF6FF), shape: BoxShape.circle),
              child: const Icon(Icons.fingerprint, color: ssBlue600, size: 38),
            ),
            const SizedBox(height: 16),
            const Text("Aktifkan Sidik Jari?",
                style: TextStyle(fontFamily: 'Nunito', fontSize: 18,
                    fontWeight: FontWeight.w900, color: ssGray800)),
            const SizedBox(height: 8),
            const Text("Masuk lebih cepat tanpa ketik password.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: ssGray500)),
            const SizedBox(height: 20),
            SSButton(
              label: "Aktifkan",
              isLoading: false,
              onPressed: () async {
                await BiometricService.setEnabled(true);
                if (!mounted) return;
                Navigator.pop(context);
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const HomePage()));
              },
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(context,
                    MaterialPageRoute(builder: (_) => const HomePage()));
              },
              child: const Text("Nanti saja",
                  style: TextStyle(color: ssGray400, fontSize: 13,
                      fontWeight: FontWeight.w600)),
            ),
          ],
        ),
      ),
    );
  }

  void _doLogin() async {
    setState(() { _error = ""; });
    if (_email.text.isEmpty || _pass.text.isEmpty) {
      setState(() => _error = "Email dan password wajib diisi");
      return;
    }
    setState(() => _loading = true);
    final res = await ServiceApi.login(_email.text.trim(), _pass.text);
    if (!mounted) return;
    setState(() => _loading = false);

    if (res['status'] == 'success') {
      // ✅ ubah: tawarkan biometrik dulu jika belum aktif
      final supported = await BiometricService.isSupported();
      final enabled   = await BiometricService.isEnabled();
      if (supported && !enabled) {
        _tawarkanBiometrik();
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const HomePage()));
      }
    } else {
      setState(() => _error = res['message'] ?? "Login gagal");
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
                    BoxShadow(color: Color(0x0F000000),
                        blurRadius: 16, offset: Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    const Text("Masuk Akun",
                        style: TextStyle(fontFamily: 'Nunito',
                            fontSize: 26, fontWeight: FontWeight.w900,
                            color: ssGray800)),
                    const SizedBox(height: 4),
                    const Text("Selamat datang kembali 👋",
                        style: TextStyle(fontSize: 13.5, color: ssGray500)),
                    const SizedBox(height: 28),

                    // Email
                    _label("Email"),
                    const SizedBox(height: 5),
                    TextField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: ssGray800, fontSize: 14),
                      decoration: ssInput(hint: "contoh@email.com"),
                    ),
                    const SizedBox(height: 14),

                    // Password
                    _label("Password"),
                    const SizedBox(height: 5),
                    TextField(
                      controller: _pass,
                      obscureText: !_showPass,
                      style: const TextStyle(color: ssGray800, fontSize: 14),
                      onSubmitted: (_) => _doLogin(),
                      decoration: ssInput(
                        hint: "Masukkan password",
                        suffix: IconButton(
                          icon: Icon(
                            _showPass ? Icons.visibility : Icons.visibility_off,
                            color: ssGray400, size: 20),
                          onPressed: () =>
                              setState(() => _showPass = !_showPass),
                        ),
                      ),
                    ),

                    // Lupa password
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.push(context,
                            MaterialPageRoute(
                                builder: (_) => const ForgotEmailPage())),
                        style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 8)),
                        child: const Text("Lupa kata sandi?",
                            style: TextStyle(color: ssBlue600, fontSize: 12.5,
                                fontWeight: FontWeight.w600)),
                      ),
                    ),

                    // Error
                    SSError(message: _error),
                    const SizedBox(height: 12),

                    // Tombol masuk
                    SSButton(
                        label: "Masuk",
                        isLoading: _loading,
                        onPressed: _doLogin),
                    const SizedBox(height: 14),

                    // ✅ Tombol sidik jari (hanya muncul jika sudah diaktifkan)
                    if (_biometricReady) ...[
                      Row(children: const [
                        Expanded(child: Divider(color: ssGray200)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 10),
                          child: Text("atau",
                              style: TextStyle(color: ssGray400, fontSize: 12)),
                        ),
                        Expanded(child: Divider(color: ssGray200)),
                      ]),
                      const SizedBox(height: 14),
                      GestureDetector(
                        onTap: _loginBiometrik,
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          decoration: BoxDecoration(
                            border: Border.all(color: ssBlue500, width: 1.8),
                            borderRadius: BorderRadius.circular(10),
                            color: const Color(0xffEFF6FF),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.fingerprint, color: ssBlue600, size: 24),
                              SizedBox(width: 8),
                              Text("Masuk dengan Sidik Jari",
                                  style: TextStyle(color: ssBlue600,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],

                    // Daftar
                    Center(
                      child: RichText(
                        text: TextSpan(
                          style: const TextStyle(fontSize: 13, color: ssGray500),
                          children: [
                            const TextSpan(text: "Belum punya akun? "),
                            WidgetSpan(
                              child: GestureDetector(
                                onTap: () => Navigator.push(context,
                                    MaterialPageRoute(
                                        builder: (_) => const RegisterPage())),
                                child: const Text("Daftar",
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

  Widget _label(String text) => Text(text,
      style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600,
          color: ssGray600, letterSpacing: 0.3));
}
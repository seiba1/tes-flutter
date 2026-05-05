import 'package:flutter/material.dart';
import '../Service/serviceapi.dart';
import './ss_them.dart';
import 'verifotp.dart';
import 'login.dart';

class ForgotEmailPage extends StatefulWidget {
  const ForgotEmailPage({super.key});
  @override
  State<ForgotEmailPage> createState() => _ForgotEmailPageState();
}

class _ForgotEmailPageState extends State<ForgotEmailPage> {
  final _email = TextEditingController();
  bool _loading = false;
  String _error = "";

  @override
  void dispose() { _email.dispose(); super.dispose(); }

  void _kirim() async {
    setState(() => _error = "");
    if (_email.text.isEmpty) {
      setState(() => _error = "Email wajib diisi"); return;
    }
    setState(() => _loading = true);
    final res = await ServiceApi.kirimOtp(_email.text.trim());
    if (!mounted) return;
    setState(() => _loading = false);
    if (res['status'] == 'success') {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => ForgotOtpPage(email: _email.text.trim()),
      ));
    } else {
      setState(() => _error = res['message'] ?? "Email tidak ditemukan");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: bgGradient,
        // ← Tidak pakai SingleChildScrollView agar tidak bisa scroll
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 440),
                padding: const EdgeInsets.fromLTRB(40, 44, 40, 36),
                decoration: BoxDecoration(
                  color: ssWhite,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [
                    BoxShadow(color: Color(0x242563EB),
                        blurRadius: 60, offset: Offset(0, 20)),
                    BoxShadow(color: Color(0x0F000000),
                        blurRadius: 16, offset: Offset(0, 4)),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Step indicator
                    const SSStepIndicator(current: 1),
                    const SizedBox(height: 28),

                    // Icon
                    Container(
                      width: 68, height: 68,
                      decoration: BoxDecoration(
                        color: const Color(0xffEFF6FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.mail_outline_rounded,
                          color: ssBlue600, size: 30),
                    ),
                    const SizedBox(height: 20),

                    const Text("Lupa Kata Sandi?",
                        style: TextStyle(fontFamily: 'Nunito',
                            fontSize: 24, fontWeight: FontWeight.w900,
                            color: ssGray800)),
                    const SizedBox(height: 8),
                    RichText(
                      textAlign: TextAlign.center,
                      text: const TextSpan(
                        style: TextStyle(fontSize: 13.5, color: ssGray500,
                            height: 1.6),
                        children: [
                          TextSpan(text: "Masukkan email terdaftar. Kami akan mengirim kode OTP yang berlaku "),
                          TextSpan(text: "5 menit",
                              style: TextStyle(fontWeight: FontWeight.w700,
                                  color: ssGray800)),
                          TextSpan(text: "."),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),

                    // Email field
                    Align(alignment: Alignment.centerLeft,
                      child: const Text("Alamat Email",
                          style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600,
                              color: ssGray600))),
                    const SizedBox(height: 5),
                    TextField(
                      controller: _email,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: ssGray800, fontSize: 14),
                      onSubmitted: (_) => _kirim(),
                      decoration: ssInput(
                        hint: "contoh@email.com",
                        prefix: const Icon(Icons.mail_outline,
                            color: ssGray400, size: 18),
                      ),
                    ),

                    SSError(message: _error),
                    const SizedBox(height: 22),

                    SSButton(
                        label: "Kirim Kode OTP",
                        isLoading: _loading,
                        onPressed: _kirim),
                    const SizedBox(height: 20),

                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (_) => const LoginPage())),
                      child: const Text("Ingat kata sandi? ← Kembali Masuk",
                          style: TextStyle(color: ssBlue600, fontSize: 13,
                              fontWeight: FontWeight.w600)),
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
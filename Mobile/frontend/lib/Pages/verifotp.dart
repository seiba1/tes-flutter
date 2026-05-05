import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Service/serviceapi.dart';
import './ss_them.dart';
import 'ubahpass.dart';
import 'login.dart';

class ForgotOtpPage extends StatefulWidget {
  final String email;
  const ForgotOtpPage({super.key, required this.email});
  @override
  State<ForgotOtpPage> createState() => _ForgotOtpPageState();
}

class _ForgotOtpPageState extends State<ForgotOtpPage> {
  // 6 controller untuk 6 kotak OTP
  final List<TextEditingController> _ctrls = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focus = List.generate(6, (_) => FocusNode());
  bool _loading = false;
  String _error = "";
  int _seconds = 300; // 5 menit
  bool _expired = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return false;
      setState(() {
        if (_seconds > 0) {
          _seconds--;
        } else {
          _expired = true;
        }
      });
      return _seconds > 0;
    });
  }

  String get _timerText {
    final m = _seconds ~/ 60;
    final s = _seconds % 60;
    return "${m.toString().padLeft(1, '0')}:${s.toString().padLeft(2, '0')}";
  }

  String get _otp => _ctrls.map((c) => c.text).join();

  @override
  void dispose() {
    for (var c in _ctrls) c.dispose();
    for (var f in _focus) f.dispose();
    super.dispose();
  }

  void _verifikasi() async {
    setState(() => _error = "");
    if (_otp.length != 6) {
      setState(() => _error = "Masukkan 6 digit kode OTP");
      return;
    }
    if (_expired) {
      setState(() => _error = "OTP sudah kadaluarsa, minta ulang");
      return;
    }
    setState(() => _loading = true);
    final res = await ServiceApi.verifikasiOtp(widget.email, _otp);
    if (!mounted) return;
    setState(() => _loading = false);
    if (res['status'] == 'success') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ForgotResetPage(email: widget.email, otp: _otp),
        ),
      );
    } else {
      setState(() => _error = res['message'] ?? "OTP tidak valid");
      // Shake/clear boxes on error
      for (var c in _ctrls) c.clear();
      _focus[0].requestFocus();
    }
  }

  void _kirimUlang() async {
    for (var c in _ctrls) c.clear();
    setState(() {
      _error = "";
      _seconds = 300;
      _expired = false;
    });
    _startTimer();
    await ServiceApi.kirimOtp(widget.email);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("OTP baru telah dikirim"),
        backgroundColor: ssGreenD,
      ),
    );
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
                padding: const EdgeInsets.fromLTRB(40, 44, 40, 36),
                decoration: BoxDecoration(
                  color: ssWhite,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x242563EB),
                      blurRadius: 60,
                      offset: Offset(0, 20),
                    ),
                    BoxShadow(
                      color: Color(0x0F000000),
                      blurRadius: 16,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SSStepIndicator(current: 2),
                    const SizedBox(height: 28),

                    Container(
                      width: 68,
                      height: 68,
                      decoration: const BoxDecoration(
                        color: Color(0xffF5F3FF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.lock_outline_rounded,
                        color: (ssBlue600),
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 20),

                    const Text(
                      "Masukkan Kode OTP",
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: ssGray800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: ssGray500,
                          height: 1.6,
                        ),
                        children: [
                          const TextSpan(text: "Kode 6 digit dikirim ke "),
                          TextSpan(
                            text: widget.email,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: ssGray800,
                            ),
                          ),
                          const TextSpan(text: ".\nCek folder "),
                          const TextSpan(
                            text: "Spam",
                            style: TextStyle(fontStyle: FontStyle.italic),
                          ),
                          const TextSpan(
                            text: " jika tidak ada di kotak masuk.",
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── 6 kotak OTP ──
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(6, (i) => _otpBox(i)),
                    ),
                    const SizedBox(height: 10),

                    // Timer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 14,
                          color: _expired ? ssRed : ssGray400,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _expired
                              ? "OTP kadaluarsa"
                              : "Berlaku selama $_timerText",
                          style: TextStyle(
                            fontSize: 12.5,
                            color: _expired ? ssRed : ssGray400,
                          ),
                        ),
                      ],
                    ),

                    SSError(message: _error),
                    const SizedBox(height: 22),

                    SSButton(
                      label: "Verifikasi Kode",
                      isLoading: _loading,
                      onPressed: _verifikasi,
                      colors: const [ssBlue500, ssBlue600],
                    ),
                    const SizedBox(height: 16),

                    GestureDetector(
                      onTap: _kirimUlang,
                      child: const Text(
                        "Tidak menerima kode? Kirim ulang",
                        style: TextStyle(
                          color: ssBlue600,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const LoginPage()),
                      ),
                      child: const Text(
                        "← Kembali ke Login",
                        style: TextStyle(
                          color: ssBlue600,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
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

  Widget _otpBox(int i) {
    return Container(
      width: 46,
      height: 54,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: TextField(
        controller: _ctrls[i],
        focusNode: _focus[i],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: ssGray800,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        decoration: InputDecoration(
          counterText: "",
          filled: true,
          fillColor: ssGray50,
          contentPadding: EdgeInsets.zero,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: ssGray200, width: 1.8),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: ssBlue500, width: 2),
          ),
        ),
        onChanged: (val) {
          if (val.isNotEmpty && i < 5) {
            _focus[i + 1].requestFocus();
          }
          if (val.isEmpty && i > 0) {
            _focus[i - 1].requestFocus();
          }
          setState(() {});
        },
      ),
    );
  }
}

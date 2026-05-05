import 'package:flutter/material.dart';

// ── Colors ───────────────────────────────────────────────────
const Color ssBlue500 = Color(0xff3B82F6);
const Color ssBlue600 = Color(0xff2563EB);
const Color ssBlue700 = Color(0xff1D4ED8);
const Color ssGray50  = Color(0xffF8FAFC);
const Color ssGray100 = Color(0xffF1F5F9);
const Color ssGray200 = Color(0xffE2E8F0);
const Color ssGray300 = Color(0xffCBD5E1);
const Color ssGray400 = Color(0xff94A3B8);
const Color ssGray500 = Color(0xff64748B);
const Color ssGray600 = Color(0xff475569);
const Color ssGray800 = Color(0xff1E293B);
const Color ssGreen   = Color(0xff22C55E);
const Color ssGreenD  = Color(0xff16A34A);
const Color ssRed     = Color(0xffEF4444);
const Color ssWhite   = Color(0xffffffff);

// Background gradient (sama seperti CSS web)
const bgGradient = BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xffE8F0FE), Color(0xffF0F7FF), Color(0xffE0ECFF)],
  ),
);

// ── Input decoration ─────────────────────────────────────────
InputDecoration ssInput({
  required String hint,
  Widget? prefix,
  Widget? suffix,
}) =>
    InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: ssGray300, fontSize: 14),
      filled: true,
      fillColor: ssGray50,
      prefixIcon: prefix,
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: ssGray200, width: 1.8),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: ssBlue500, width: 1.8),
      ),
    );

// ── Gradient Button ───────────────────────────────────────────
class SSButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback? onPressed;
  final List<Color> colors;

  const SSButton({
    super.key,
    required this.label,
    required this.isLoading,
    required this.onPressed,
    this.colors = const [ssBlue500, ssBlue600],
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: isLoading
            ? const LinearGradient(colors: [ssGray200, ssGray200])
            : LinearGradient(colors: colors),
        borderRadius: BorderRadius.circular(8),
        boxShadow: isLoading
            ? []
            : [BoxShadow(
                color: colors.last.withOpacity(0.38),
                blurRadius: 16, offset: const Offset(0, 4))],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: isLoading ? null : onPressed,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    height: 20, width: 20,
                    child: CircularProgressIndicator(
                        color: ssGray400, strokeWidth: 2.5))
                : Text(label,
                    style: const TextStyle(
                        color: ssWhite, fontSize: 15,
                        fontWeight: FontWeight.w700, letterSpacing: 0.3)),
          ),
        ),
      ),
    );
  }
}

// ── Step Indicator ────────────────────────────────────────────
class SSStepIndicator extends StatelessWidget {
  final int current;
  const SSStepIndicator({super.key, required this.current});

  @override
  Widget build(BuildContext context) {
    final steps = ["Email", "Verifikasi", "Reset"];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(steps.length, (i) {
        final step = i + 1;
        final isDone = step < current;
        final isActive = step == current;
        return Row(
          children: [
            Column(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: (isDone || isActive) ? ssBlue600 : ssGray100,
                  border: Border.all(
                    color: (isDone || isActive) ? ssBlue600 : ssGray200,
                    width: 2,
                  ),
                  boxShadow: isActive
                      ? [BoxShadow(color: ssBlue500.withOpacity(0.3),
                          blurRadius: 8, spreadRadius: 2)]
                      : [],
                ),
                child: Center(
                  child: isDone
                      ? const Icon(Icons.check_rounded, color: ssWhite, size: 16)
                      : Text("$step",
                          style: TextStyle(
                            color: isActive ? ssWhite : ssGray400,
                            fontSize: 13, fontWeight: FontWeight.w700,
                          )),
                ),
              ),
              const SizedBox(height: 5),
              Text(steps[i],
                  style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600,
                    color: isActive ? ssBlue600 : ssGray400,
                  )),
            ]),
            if (i < steps.length - 1)
              Container(
                width: 48, height: 2,
                margin: const EdgeInsets.only(bottom: 20),
                color: isDone ? ssBlue600 : ssGray200,
              ),
          ],
        );
      }),
    );
  }
}

// ── Error box ─────────────────────────────────────────────────
class SSError extends StatelessWidget {
  final String message;
  const SSError({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    if (message.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: const Color(0xffFEF2F2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xffFECACA), width: 1),
      ),
      child: Text(message,
          style: const TextStyle(color: ssRed, fontSize: 13,
              fontWeight: FontWeight.w600)),
    );
  }
}
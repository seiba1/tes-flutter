import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricService {
  static final LocalAuthentication _auth = LocalAuthentication();

  // Cek apakah HP support biometrik
  static Future<bool> isSupported() async {
    try {
      return await _auth.canCheckBiometrics && await _auth.isDeviceSupported();
    } catch (e) {
      return false;
    }
  }

  // Cek apakah user sudah aktifkan biometrik di app ini
  static Future<bool> isEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('biometric_enabled') ?? false;
  }

  // Simpan status aktif/nonaktif biometrik
  static Future<void> setEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('biometric_enabled', value);
  }

  // Tampilkan prompt sidik jari
  static Future<bool> authenticate() async {
    try {
      return await _auth.authenticate(
        localizedReason: 'Gunakan sidik jari untuk masuk ke SmartStudio',
        options: const AuthenticationOptions(
          stickyAuth: true,      // tetap tampil meski pindah app
          biometricOnly: false,  // false = boleh pakai PIN juga sebagai fallback
        ),
      );
    } catch (e) {
      return false;
    }
  }

  // Hapus status biometrik (saat logout)
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('biometric_enabled');
  }
}
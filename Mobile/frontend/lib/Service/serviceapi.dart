import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../Service/biometric_service.dart'; 
import 'dart:convert';

class ServiceApi {
  // ⚠️ Ganti IP dengan IP laptop kamu (ipconfig → IPv4 Address)
  static String baseUrl = kIsWeb
      ? "http://127.0.0.1:8000/api"
      : "http://192.168.1.16:8000/api";

  static Map<String, String> get _json => {
    "Content-Type": "application/json",
    "Accept": "application/json",
  };

  static Future<Map<String, String>> _auth() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      "Content-Type": "application/json",
      "Accept": "application/json",
      "Authorization": "Bearer ${prefs.getString('token') ?? ''}",
    };
  }

  static Future _save(Map data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", data["token"] ?? "");
    await prefs.setString("user", jsonEncode(data["user"]));
    await prefs.setString("role", data["user"]["role"] ?? "user");
    await prefs.setString("username", data["user"]["username"] ?? "");
    await prefs.setString("email", data["user"]["email"] ?? "");
  }

  static Future clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  static Future<Map<String, String>> getUserInfo() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      "username": prefs.getString("username") ?? "User",
      "email": prefs.getString("email") ?? "",
      "role": prefs.getString("role") ?? "user",
    };
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return (prefs.getString("token") ?? "").isNotEmpty;
  }

  // ── LOGIN ──────────────────────────────────────
  static Future login(String email, String password) async {
    try {
      var res = await http
          .post(
            Uri.parse("$baseUrl/login"),
            headers: _json,
            body: jsonEncode({"email": email, "password": password}),
          )
          .timeout(const Duration(seconds: 15));
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data["status"] == "success") {
        await _save(data);
      }
      return data;
    } catch (e) {
      return {
        "status": "error",
        "message": "Koneksi gagal. Cek server Laravel.",
      };
    }
  }

  // ── REGISTER ───────────────────────────────────
  static Future register(Map data) async {
    try {
      var res = await http
          .post(
            Uri.parse("$baseUrl/register"),
            headers: _json,
            body: jsonEncode({
              "username": data["username"],
              "email": data["email"],
              "no_hp": data["no_hp"],
              "password": data["password"],
            }),
          )
          .timeout(const Duration(seconds: 15));
      return jsonDecode(res.body);
    } catch (e) {
      return {
        "status": "error",
        "message": "Koneksi gagal. Cek server Laravel.",
      };
    }
  }

  // ── KIRIM OTP ──────────────────────────────────
  static Future kirimOtp(String email) async {
    try {
      var res = await http
          .post(
            Uri.parse("$baseUrl/lupapass"),
            headers: _json,
            body: jsonEncode({"email": email}),
          )
          .timeout(const Duration(seconds: 180));
      return jsonDecode(res.body);
    } catch (e) {
      return {
        "status": "error",
        "message": "Koneksi gagal. Cek server Laravel.",
      };
    }
  }

  // ── VERIFIKASI OTP ─────────────────────────────
  static Future verifikasiOtp(String email, String otp) async {
    try {
      var res = await http
          .post(
            Uri.parse("$baseUrl/verifotp"),
            headers: _json,
            body: jsonEncode({"email": email, "otp": otp}),
          )
          .timeout(const Duration(seconds: 15));
      return jsonDecode(res.body);
    } catch (e) {
      return {"status": "error", "message": "Koneksi gagal."};
    }
  }

  // ── RESET PASSWORD ─────────────────────────────
  static Future resetPassword(String email, String otp, String pass) async {
    try {
      var res = await http
          .post(
            Uri.parse("$baseUrl/ubahpass"),
            headers: _json,
            body: jsonEncode({"email": email, "otp": otp, "password": pass}),
          )
          .timeout(const Duration(seconds: 15));
      return jsonDecode(res.body);
    } catch (e) {
      return {"status": "error", "message": "Koneksi gagal."};
    }
  }

  // ── LOGOUT ─────────────────────────────────────
  static Future logout() async {
    final headers = await _auth();
    await clear();
    await BiometricService.clear();
    try {
      await http
          .post(Uri.parse("$baseUrl/logout"), headers: headers)
          .timeout(const Duration(seconds: 10));
    } catch (_) {}
  }

  // ── GET KAMERA ─────────────────────────────────
  static Future getKamera() async {
    try {
      var res = await http
          .get(Uri.parse("$baseUrl/kamera"), headers: await _auth())
          .timeout(const Duration(seconds: 15));
      return jsonDecode(res.body);
    } catch (e) {
      return {"status": "error", "message": "Koneksi gagal."};
    }
  }
}

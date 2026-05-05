<?php
// app/Services/AuthService.php

namespace App\Services;

use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Mail;
use App\Models\User;

class AuthService
{
    // ============================================================
    // LOGIN
    // Alur: cek email → verif password → cek role → buat token
    // ============================================================
    public function login($request)
    {
        // Validasi input kosong
        if (!$request->email || !$request->password) {
            return [
                "status"  => "error",
                "message" => "Email dan password wajib diisi"
            ];
        }

        // Cari user berdasarkan email di tabel users
        // Pakai Eloquent (User model) bukan DB::table
        // karena kita butuh createToken() dari Sanctum
        $user = User::where('email', $request->email)->first();

        // Jika email tidak ditemukan ATAU password salah
        if (!$user || !password_verify($request->password, $user->password)) {
            return [
                "status"  => "error",
                "message" => "Email atau password salah"
            ];
        }

        // Hapus semua token lama milik user ini
        // Supaya tidak numpuk token di database
        $user->tokens()->delete();

        // Buat token baru
        // 'smartstudio-token' adalah nama token, bebas diisi apa saja
        $token = $user->createToken('smartstudio-token')->plainTextToken;

        // Kembalikan token + data user termasuk ROLE
        // React akan simpan role ini di localStorage
        // lalu arahkan ke halaman admin atau user
        return [
            "status"  => "success",
            "message" => "Login berhasil",
            "token"   => $token,
            "user"    => [
                "id"       => $user->id,
                "username" => $user->username,
                "email"    => $user->email,
                "no_hp"    => $user->no_hp,
                "role"     => $user->role,  // "admin" atau "user"
            ]
        ];
    }

    // ============================================================
    // REGISTER
    // ============================================================
    public function register($request)
    {
        // Validasi semua field wajib ada
        if (!$request->username || !$request->email || 
            !$request->no_hp   || !$request->password) {
            return [
                "status"  => "error",
                "message" => "Semua field wajib diisi"
            ];
        }

        // Cek format email valid
        if (!filter_var($request->email, FILTER_VALIDATE_EMAIL)) {
            return [
                "status"  => "error",
                "message" => "Format email tidak valid"
            ];
        }

        // Cek email sudah terdaftar
        if (DB::table('users')->where('email', $request->email)->exists()) {
            return [
                "status"  => "error",
                "message" => "Email sudah terdaftar"
            ];
        }

        // Cek panjang password
        if (strlen($request->password) < 8) {
            return [
                "status"  => "error",
                "message" => "Password minimal 8 karakter"
            ];
        }

        // Simpan user baru
        // Role default adalah "user", bukan "admin"
        DB::table('users')->insert([
            "username"   => $request->username,
            "email"      => $request->email,
            "no_hp"      => $request->no_hp,
            "password"   => password_hash($request->password, PASSWORD_DEFAULT),
            "role"       => "user",   // default selalu "user"
            "created_at" => now(),
            "updated_at" => now(),
        ]);

        return [
            "status"  => "success",
            "message" => "Registrasi berhasil, silakan login"
        ];
    }

    // ============================================================
    // LUPA PASSWORD — Kirim OTP ke email
    // ============================================================
    public function lupaPass($request)
    {
        if (!$request->email) {
            return ["status" => "error", "message" => "Email wajib diisi"];
        }

        $user = DB::table('users')->where('email', $request->email)->first();

        if (!$user) {
            return ["status" => "error", "message" => "Email tidak ditemukan"];
        }

        // Generate OTP 6 digit + waktu expired 5 menit dari sekarang
        $otp     = rand(100000, 999999);
        $expired = now()->addMinutes(5);

        DB::table('users')->where('email', $request->email)->update([
            "otp"         => $otp,
            "otp_expired" => $expired,
        ]);

        $otpStr = (string) $otp;

        // Template email HTML
        $html = '
        <!DOCTYPE html>
        <html>
        <head><meta charset="UTF-8"></head>
        <body style="margin:0;padding:0;background:#f0f4ff;
                     font-family:\'Segoe UI\',Arial,sans-serif">
        <table width="100%" cellpadding="0" cellspacing="0">
        <tr><td align="center" style="padding:32px 16px">
        <table width="480" cellpadding="0" cellspacing="0"
            style="max-width:480px;width:100%;background:#fff;
                   border-radius:20px;overflow:hidden;
                   box-shadow:0 8px 32px rgba(24,95,165,0.12)">

            <tr><td style="height:6px;
                background:linear-gradient(90deg,#185FA5,#378ADD);
                font-size:0">&nbsp;</td></tr>

            <tr><td style="padding:36px;text-align:center">

                <p style="font-size:20px;font-weight:900;color:#051225;
                           margin:0 0 4px">
                    Smart<span style="color:#185FA5">Studio</span>
                </p>
                <p style="font-size:13px;color:#6a8aaa;margin:0 0 28px">
                    Kode verifikasi akun kamu
                </p>

                <table width="100%" cellpadding="0" cellspacing="0"
                    style="background:#E6F1FB;border:2px solid #B5D4F4;
                           border-radius:16px">
                <tr><td style="padding:28px;text-align:center">
                    <p style="font-size:42px;font-weight:900;
                               color:#185FA5;letter-spacing:14px;
                               margin:0;line-height:1">' . $otpStr . '</p>
                </td></tr>
                </table>

                <table width="100%" cellpadding="0" cellspacing="0"
                       style="margin-top:16px">
                <tr><td style="background:#fffbeb;border:1px solid #fde68a;
                                border-radius:10px;padding:12px;
                                text-align:center;font-size:13px;
                                font-weight:600;color:#92400e">
                    ⏱ Kode berlaku selama 5 menit
                </td></tr>
                </table>

                <p style="font-size:12px;color:#aabbd0;margin-top:20px">
                    Abaikan email ini jika kamu tidak memintanya.
                </p>

            </td></tr>
        </table>
        </td></tr>
        </table>
        </body>
        </html>';

        Mail::html($html, function ($message) use ($request) {
            $message->to($request->email)
                    ->subject('Kode OTP — SmartStudio');
        });

        return ["status" => "success", "message" => "OTP berhasil dikirim ke email"];
    }

    // ============================================================
    // VERIF OTP
    // ============================================================
    public function verifOtp($request)
    {
        if (!$request->email || !$request->otp) {
            return ["status" => "error", "message" => "Data tidak lengkap"];
        }

        $user = DB::table('users')
            ->where('email', $request->email)
            ->where('otp', $request->otp)
            ->first();

        if (!$user) {
            return ["status" => "error", "message" => "OTP salah"];
        }

        // Bandingkan waktu expired dengan waktu sekarang
        // now()->gt() artinya "sekarang lebih besar dari expired?"
        if (now()->gt($user->otp_expired)) {
            return ["status" => "error", "message" => "OTP sudah kadaluarsa, minta ulang"];
        }

        return ["status" => "success", "message" => "OTP valid"];
    }

    // ============================================================
    // RESET PASSWORD
    // ============================================================
    public function ubahPass($request)
    {
        if (!$request->email || !$request->password) {
            return ["status" => "error", "message" => "Data tidak lengkap"];
        }

        if (strlen($request->password) < 8) {
            return ["status" => "error", "message" => "Password minimal 8 karakter"];
        }

        $user = DB::table('users')->where('email', $request->email)->first();
        if (!$user) {
            return ["status" => "error", "message" => "User tidak ditemukan"];
        }

        DB::table('users')->where('email', $request->email)->update([
            "password"    => password_hash($request->password, PASSWORD_DEFAULT),
            "otp"         => null,   // hapus OTP setelah berhasil
            "otp_expired" => null,   // hapus expired setelah berhasil
            "updated_at"  => now(),
        ]);

        return ["status" => "success", "message" => "Password berhasil diubah"];
    }
}
<?php
// app/Http/Controllers/AuthController.php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Services\AuthService;

class AuthController extends Controller
{
    protected $authService;

    public function __construct(AuthService $authService)
    {
        $this->authService = $authService;
    }

    public function login(Request $request)
    {
        $result = $this->authService->login($request);
        // 200 = berhasil, 401 = email/password salah
        $status = $result['status'] === 'success' ? 200 : 401;
        return response()->json($result, $status);
    }

    public function register(Request $request)
    {
        $result = $this->authService->register($request);
        // 201 = berhasil dibuat, 422 = validasi gagal
        $status = $result['status'] === 'success' ? 201 : 422;
        return response()->json($result, $status);
    }

    public function lupaPass(Request $request)
    {
        $result = $this->authService->lupaPass($request);
        // 404 = email tidak ditemukan
        $status = $result['status'] === 'success' ? 200 : 404;
        return response()->json($result, $status);
    }

    public function verifOtp(Request $request)
    {
        $result = $this->authService->verifOtp($request);
        // 400 = OTP salah atau kadaluarsa
        $status = $result['status'] === 'success' ? 200 : 400;
        return response()->json($result, $status);
    }

    public function ubahPass(Request $request)
    {
        $result = $this->authService->ubahPass($request);
        $status = $result['status'] === 'success' ? 200 : 400;
        return response()->json($result, $status);
    }

    // Logout — hapus token yang sedang dipakai
    // Hanya bisa diakses jika ada token (middleware auth:sanctum)
    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();
        return response()->json([
            "status"  => "success",
            "message" => "Logout berhasil"
        ]);
    }

    // Profile — ambil data user yang sedang login
    public function profile(Request $request)
    {
        $user = $request->user(); // ambil dari token
        return response()->json([
            "status" => "success",
            "user"   => [
                "id"       => $user->id,
                "username" => $user->username,
                "email"    => $user->email,
                "no_hp"    => $user->no_hp,
                "role"     => $user->role,
            ]
        ]);
    }
}
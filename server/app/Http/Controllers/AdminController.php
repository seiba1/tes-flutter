<?php
// app/Http/Controllers/AdminController.php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AdminController extends Controller
{
    // GET /admin/dashboard
    // Statistik untuk ditampilkan di halaman admin
    public function stats()
    {
        // Hitung total user biasa (role = user)
        $totalUsers = DB::table('users')
            ->where('role', 'user')
            ->count();

        // Hitung total admin (role = admin)
        $totalAdmin = DB::table('users')
            ->where('role', 'admin')
            ->count();

        // User baru dalam 7 hari terakhir
        $userBaru = DB::table('users')
            ->where('role', 'user')
            ->where('created_at', '>=', now()->subDays(7))
            ->count();

        // Hitung kamera dan history jika tabelnya ada
        $totalKamera  = DB::table('kamera')->count();
        $totalHistory = DB::table('history')->count();

        return response()->json([
            "status" => "success",
            "data"   => [
                "total_users"   => $totalUsers,
                "total_admin"   => $totalAdmin,
                "user_baru"     => $userBaru,
                "total_kamera"  => $totalKamera,
                "total_history" => $totalHistory,
            ]
        ]);
    }

    // GET /admin/users
    // Ambil semua user (kecuali admin) untuk ditampilkan di tabel
    public function index()
    {
        $users = DB::table('users')
            ->where('role', 'user')             // hanya tampilkan user biasa
            ->select('id', 'username', 'email', 
                     'no_hp', 'role', 'created_at')
            ->orderBy('created_at', 'desc')     // terbaru dulu
            ->get();

        return response()->json([
            "status" => "success",
            "data"   => $users
        ]);
    }

    // DELETE /admin/users/{id}
    // Hapus user berdasarkan id
    public function destroy($id)
    {
        $user = DB::table('users')->where('id', $id)->first();

        if (!$user) {
            return response()->json([
                "status"  => "error",
                "message" => "User tidak ditemukan"
            ], 404);
        }

        // Jangan izinkan hapus akun admin
        if ($user->role === 'admin') {
            return response()->json([
                "status"  => "error",
                "message" => "Tidak bisa menghapus akun admin"
            ], 403);
        }

        DB::table('users')->where('id', $id)->delete();

        return response()->json([
            "status"  => "success",
            "message" => "User berhasil dihapus"
        ]);
    }

    // PUT /admin/users/{id}/role — ubah role user
    public function updateRole(Request $request, $id)
    {
        $user = DB::table('users')->where('id', $id)->first();

        if (!$user) {
            return response()->json([
                "status"  => "error",
                "message" => "User tidak ditemukan"
            ], 404);
        }

        $roleValid = ['admin', 'user'];
        if (!in_array($request->role, $roleValid)) {
            return response()->json([
                "status"  => "error",
                "message" => "Role tidak valid"
            ], 422);
        }

        DB::table('users')->where('id', $id)->update([
            'role'       => $request->role,
            'updated_at' => now(),
        ]);

        return response()->json([
            "status"  => "success",
            "message" => "Role berhasil diubah"
        ]);
    }
}
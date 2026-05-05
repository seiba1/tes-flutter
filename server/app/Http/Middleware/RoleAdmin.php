<?php
// app/Http/Middleware/RoleAdmin.php
// Jalankan: php artisan make:middleware RoleAdmin
// Lalu daftarkan di bootstrap/app.php (Laravel 11) atau Kernel.php (Laravel 10)

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;

class RoleAdmin
{
    public function handle(Request $request, Closure $next)
    {
        // Pastikan user sudah login (sudah dicek auth:sanctum sebelumnya)
        $user = $request->user();

        if (!$user || $user->role !== 'admin') {
            return response()->json([
                "status"  => "error",
                "message" => "Akses ditolak. Hanya admin yang diizinkan."
            ], 403);
        }

        return $next($request);
    }
}
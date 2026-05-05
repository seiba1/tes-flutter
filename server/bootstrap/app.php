<?php
// bootstrap/app.php  (Laravel 11)
// Tambahkan alias middleware 'role.admin' di sini

use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
    )
    ->withMiddleware(function (Middleware $middleware) {

        // ── Daftarkan alias middleware 'role.admin' ──
        $middleware->alias([
            'role.admin' => \App\Http\Middleware\RoleAdmin::class,
        ]);

    })
    ->withExceptions(function (Exceptions $exceptions) {
        //
    })->create();

// ============================================================
// CATATAN untuk Laravel 10 (Kernel.php):
// Tambahkan ke $routeMiddleware di app/Http/Kernel.php:
//
// protected $routeMiddleware = [
//     ...
//     'role.admin' => \App\Http\Middleware\RoleAdmin::class,
// ];
// ============================================================
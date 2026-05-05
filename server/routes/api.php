<?php

use App\Http\Controllers\AuthController;
use App\Http\Controllers\AdminController;
// use App\Http\Controllers\KameraController; // ← comment dulu
use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\DB;

Route::post('/login',    [AuthController::class, 'login']);
Route::post('/register', [AuthController::class, 'register']);
Route::post('/lupapass', [AuthController::class, 'lupaPass']);
Route::post('/verifotp', [AuthController::class, 'verifOtp']);
Route::post('/ubahpass', [AuthController::class, 'ubahPass']);

Route::get('/test', fn() => response()->json(["status" => "ok"]));

Route::middleware('auth:sanctum')->group(function () {
    Route::post('/logout',  [AuthController::class, 'logout']);
    Route::get('/profile',  [AuthController::class, 'profile']);

    Route::middleware('role.admin')->group(function () {
        Route::get('/admin/dashboard',       [AdminController::class, 'stats']);
        Route::get('/admin/users',           [AdminController::class, 'index']);
        Route::delete('/admin/users/{id}',   [AdminController::class, 'destroy']);
        Route::put('/admin/users/{id}/role', [AdminController::class, 'updateRole']);
    });
});
<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\CalculateController;
use App\Http\Controllers\Api\CityController;
use App\Http\Controllers\Api\GunMilanController;
use App\Http\Controllers\Api\PdfController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Vedic Astrology & Kundali API Routes
|--------------------------------------------------------------------------
| Provides endpoints for authentication, Kundali calculation, Ashtakoot Gun
| Milan matchmaking, city autocomplete, and PDF report generation.
*/

// Authentication Routes (Public)
Route::post('/login', [AuthController::class, 'login'])->name('login');
Route::post('/login/send-otp', [AuthController::class, 'sendLoginOtp']);
Route::post('/signup', [AuthController::class, 'signup']);
Route::post('/signup/send-otp', [AuthController::class, 'sendSignupOtp']);
Route::post('/register', [AuthController::class, 'signup']);

// Protected Routes (Require Laravel Sanctum Bearer Token)
Route::middleware('auth:sanctum')->group(function () {
    // Current authenticated user profile & logout
    Route::get('/user', [AuthController::class, 'me']);
    Route::post('/logout', [AuthController::class, 'logout']);

    // City Autocomplete
    Route::get('/cities', CityController::class);

    // Kundali Calculation
    Route::post('/calculate', CalculateController::class);

    // Gun Milan Matchmaking
    Route::post('/gunmilan', GunMilanController::class);

    // PDF Downloads
    Route::post('/download-pdf', [PdfController::class, 'kundali']);
    Route::post('/download-gunmilan-pdf', [PdfController::class, 'gunmilan']);
});

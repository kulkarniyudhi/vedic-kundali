<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\EmailOtp;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class AuthController extends Controller
{
    /**
     * Send OTP to email for Signup.
     */
    public function sendSignupOtp(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'email' => ['required', 'string', 'email', 'max:255', 'unique:users,email'],
        ]);

        $email = strtolower(trim($validated['email']));
        $otp = EmailOtp::generate($email, 'signup');
        EmailOtp::sendEmail($email, $otp, 'signup');

        return response()->json([
            'success' => true,
            'message' => __('auth.otp_sent'),
            'email' => $email,
            'debug_otp' => app()->environment(['local', 'testing']) ? $otp : null,
        ]);
    }

    /**
     * Register a new user directly and return Sanctum access token.
     */
    public function signup(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'email', 'max:255', 'unique:users,email'],
            'password' => ['required', 'string', 'min:6'],
            'phone' => ['nullable', 'string', 'max:20'],
            'mobile' => ['nullable', 'string', 'max:20'],
        ]);

        $email = strtolower(trim($validated['email']));
        $phone = $validated['phone'] ?? $validated['mobile'] ?? null;

        $user = User::create([
            'name' => trim($validated['name']),
            'email' => $email,
            'phone' => $phone ? trim($phone) : null,
            'password' => Hash::make($validated['password']),
            'email_verified_at' => now(),
        ]);

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => __('auth.signup_success'),
            'token' => $token,
            'token_type' => 'Bearer',
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'phone' => $user->phone,
            ],
        ], 201);
    }

    /**
     * Send OTP to email for Login.
     */
    public function sendLoginOtp(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'email' => ['required', 'string', 'email'],
            'password' => ['nullable', 'string'],
        ]);

        $email = strtolower(trim($validated['email']));
        $user = User::whereRaw('LOWER(email) = ?', [$email])->first();

        if (! $user) {
            return response()->json([
                'success' => false,
                'message' => __('auth.account_not_found'),
            ], 404);
        }

        // If password is provided, verify it first before sending OTP
        if (! empty($validated['password']) && ! Hash::check($validated['password'], $user->password)) {
            return response()->json([
                'success' => false,
                'message' => __('auth.invalid_password'),
            ], 401);
        }

        $otp = EmailOtp::generate($user->email, 'login');
        EmailOtp::sendEmail($user->email, $otp, 'login');

        return response()->json([
            'success' => true,
            'message' => __('auth.otp_sent'),
            'email' => $user->email,
            'debug_otp' => app()->environment(['local', 'testing']) ? $otp : null,
        ]);
    }

    /**
     * Authenticate an existing user directly with email and password and return Sanctum access token.
     */
    public function login(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'email' => ['required', 'string', 'email'],
            'password' => ['required', 'string'],
        ]);

        $email = strtolower(trim($validated['email']));
        $user = User::whereRaw('LOWER(email) = ?', [$email])->first();

        if (! $user) {
            return response()->json([
                'success' => false,
                'message' => __('auth.account_not_found'),
            ], 404);
        }

        if (! Hash::check($validated['password'], $user->password)) {
            return response()->json([
                'success' => false,
                'message' => __('auth.failed'),
            ], 401);
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => __('auth.login_success'),
            'token' => $token,
            'token_type' => 'Bearer',
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'phone' => $user->phone,
            ],
        ]);
    }

    /**
     * Get the authenticated user's profile.
     */
    public function me(Request $request): JsonResponse
    {
        $user = $request->user();

        return response()->json([
            'success' => true,
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'phone' => $user->phone,
            ],
        ]);
    }

    /**
     * Revoke the current access token.
     */
    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => __('auth.logged_out'),
        ]);
    }
}

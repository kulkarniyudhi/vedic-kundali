<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Mail;

class EmailOtp extends Model
{
    protected $fillable = [
        'email',
        'otp',
        'type',
        'expires_at',
    ];

    protected function casts(): array
    {
        return [
            'expires_at' => 'datetime',
        ];
    }

    /**
     * Generate and store a new 6-digit OTP for the given email and type.
     */
    public static function generate(string $email, string $type = 'login', int $validMinutes = 10): string
    {
        $normalizedEmail = strtolower(trim($email));

        // Invalidate old OTPs for this email and type
        self::where('email', $normalizedEmail)
            ->where('type', $type)
            ->delete();

        $otp = sprintf('%06d', random_int(100000, 999999));

        self::create([
            'email' => $normalizedEmail,
            'otp' => $otp,
            'type' => $type,
            'expires_at' => now()->addMinutes($validMinutes),
        ]);

        return $otp;
    }

    /**
     * Send OTP email to the user.
     */
    public static function sendEmail(string $email, string $otp, string $type = 'login'): void
    {
        $actionName = $type === 'signup' ? 'नवीन खाते नोंदणी (Sign Up)' : 'खाते प्रवेश (Login)';

        $content = "॥ वैदिक कुंडली ॥\n\n"
            . "नमस्कार,\n\n"
            . "आपल्या {$actionName} साठीचा एकवेळ पासवर्ड (OTP) खालीलप्रमाणे आहे:\n\n"
            . "  [ {$otp} ]\n\n"
            . "हा OTP पुढील १० मिनिटांसाठी वैध आहे. हा कोड कोणाशीही शेअर करू नका.\n\n"
            . "--------------------------------------------------\n"
            . "Your Vedic Kundali {$type} verification code is: {$otp}\n"
            . "Valid for 10 minutes. Do not share this OTP with anyone.\n";

        try {
            Mail::raw($content, function ($message) use ($email, $actionName) {
                $message->to($email)
                    ->subject("॥ वैदिक कुंडली ॥ {$actionName} - OTP: पडताळणी कोड");
            });
        } catch (\Throwable $e) {
            // Log mail sending error without breaking local flow
            logger()->error('Failed to send OTP email: ' . $e->getMessage());
        }
    }

    /**
     * Verify the provided OTP.
     */
    public static function verify(string $email, string $otp, string $type = 'login'): bool
    {
        $normalizedEmail = strtolower(trim($email));
        $normalizedOtp = trim($otp);

        $record = self::where('email', $normalizedEmail)
            ->where('type', $type)
            ->where('expires_at', '>', now())
            ->latest()
            ->first();

        if ($record && hash_equals((string) $record->otp, (string) $normalizedOtp)) {
            $record->delete();
            return true;
        }

        return false;
    }
}

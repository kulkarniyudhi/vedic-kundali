<?php

use App\Models\EmailOtp;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Laravel\Sanctum\Sanctum;

uses(RefreshDatabase::class);

test('returns validation error messages in Marathi when lang header is mr', function () {
    User::factory()->create(['email' => 'duplicate@example.com']);

    $response = $this->withHeader('lang', 'mr')
        ->postJson('/api/signup/send-otp', [
            'email' => 'duplicate@example.com',
        ]);

    $response->assertStatus(422);
    $errors = $response->json('errors.email');
    expect($errors[0])->toBe('हा ईमेल आधीच नोंदणीकृत आहे.');
});

test('returns validation error messages in Hindi when lang header is hi', function () {
    User::factory()->create(['email' => 'duplicate@example.com']);

    $response = $this->withHeader('lang', 'hi')
        ->postJson('/api/signup/send-otp', [
            'email' => 'duplicate@example.com',
        ]);

    $response->assertStatus(422);
    $errors = $response->json('errors.email');
    expect($errors[0])->toBe('यह ईमेल पहले से पंजीकृत है.');
});

test('returns validation error messages in English when lang header is en', function () {
    User::factory()->create(['email' => 'duplicate@example.com']);

    $response = $this->withHeader('lang', 'en')
        ->postJson('/api/signup/send-otp', [
            'email' => 'duplicate@example.com',
        ]);

    $response->assertStatus(422);
    $errors = $response->json('errors.email');
    expect($errors[0])->toBe('This email is already registered.');
});

test('returns localized auth success and error messages based on lang header', function () {
    // 1. Marathi
    $resMr = $this->withHeader('lang', 'mr')
        ->postJson('/api/signup/send-otp', [
            'email' => 'marathi.user@example.com',
        ]);
    $resMr->assertStatus(200);
    expect($resMr->json('message'))->toBe('आपल्या ईमेलवर ६-अंकी OTP पाठवला आहे.');

    // 2. Hindi
    $resHi = $this->withHeader('lang', 'hi')
        ->postJson('/api/signup/send-otp', [
            'email' => 'hindi.user@example.com',
        ]);
    $resHi->assertStatus(200);
    expect($resHi->json('message'))->toBe('आपके ईमेल पर 6-अंकीय OTP भेजा गया है.');

    // 3. English
    $resEn = $this->withHeader('lang', 'en')
        ->postJson('/api/signup/send-otp', [
            'email' => 'english.user@example.com',
        ]);
    $resEn->assertStatus(200);
    expect($resEn->json('message'))->toBe('A 6-digit OTP has been sent to your email.');
});

test('detects locale from Accept-Language or X-Locale header as fallback', function () {
    User::factory()->create(['email' => 'taken@example.com']);

    // Accept-Language: hi-IN
    $res1 = $this->withHeader('Accept-Language', 'hi-IN,hi;q=0.9')
        ->postJson('/api/signup/send-otp', [
            'email' => 'taken@example.com',
        ]);
    expect($res1->json('errors.email.0'))->toBe('यह ईमेल पहले से पंजीकृत है.');

    // X-Locale: mr
    $res2 = $this->withHeader('X-Locale', 'mr')
        ->postJson('/api/signup/send-otp', [
            'email' => 'taken@example.com',
        ]);
    expect($res2->json('errors.email.0'))->toBe('हा ईमेल आधीच नोंदणीकृत आहे.');
});

test('returns localized validation error in Calculate API based on lang header', function () {
    $user = User::factory()->create();
    Sanctum::actingAs($user, ['*']);

    $resMr = $this->withHeader('lang', 'mr')
        ->postJson('/api/calculate', ['date' => '06-09-2000']);

    $resMr->assertStatus(400);
    expect($resMr->json('error'))->toBe('आवश्यक माहिती गहाळ आहे: तारीख, वेळ, अक्षांश, रेखांश');

    $resHi = $this->withHeader('lang', 'hi')
        ->postJson('/api/calculate', ['date' => '06-09-2000']);

    $resHi->assertStatus(400);
    expect($resHi->json('error'))->toBe('आवश्यक जानकारी अनुपलब्ध है: तारीख, समय, अक्षांश, देशांतर');
});

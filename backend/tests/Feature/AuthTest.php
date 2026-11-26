<?php

use App\Models\EmailOtp;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Laravel\Sanctum\Sanctum;

uses(RefreshDatabase::class);

test('user can request signup otp with valid email', function () {
    $response = $this->postJson('/api/signup/send-otp', [
        'email' => 'rahul@example.com',
    ]);

    $response->assertStatus(200)
        ->assertJson([
            'success' => true,
            'email' => 'rahul@example.com',
        ]);

    $this->assertDatabaseHas('email_otps', [
        'email' => 'rahul@example.com',
        'type' => 'signup',
    ]);
});

test('signup send-otp fails with duplicate email', function () {
    User::factory()->create(['email' => 'duplicate@example.com']);

    $response = $this->postJson('/api/signup/send-otp', [
        'email' => 'duplicate@example.com',
    ]);

    $response->assertStatus(422)
        ->assertJsonValidationErrors(['email']);
});

test('user can register directly with valid details without otp', function () {
    $response = $this->postJson('/api/signup', [
        'name' => 'राहुल कुलकर्णी',
        'email' => 'rahul@example.com',
        'phone' => '9822012345',
        'password' => 'secret123',
    ]);

    $response->assertStatus(201)
        ->assertJson([
            'success' => true,
            'token_type' => 'Bearer',
            'user' => [
                'name' => 'राहुल कुलकर्णी',
                'email' => 'rahul@example.com',
                'phone' => '9822012345',
            ],
        ])
        ->assertJsonStructure([
            'success',
            'message',
            'token',
            'token_type',
            'user' => ['id', 'name', 'email', 'phone'],
        ]);

    $this->assertDatabaseHas('users', [
        'email' => 'rahul@example.com',
        'phone' => '9822012345',
    ]);
});

test('signup allows omitting optional mobile number', function () {
    $response = $this->postJson('/api/signup', [
        'name' => 'No Mobile User',
        'email' => 'nomobile@example.com',
        'password' => 'secret123',
    ]);

    $response->assertStatus(201)
        ->assertJson([
            'success' => true,
            'user' => [
                'name' => 'No Mobile User',
                'email' => 'nomobile@example.com',
                'phone' => null,
            ],
        ]);
});

test('signup fails with duplicate email', function () {
    User::factory()->create(['email' => 'duplicate@example.com']);

    $response = $this->postJson('/api/signup', [
        'name' => 'Duplicate User',
        'email' => 'duplicate@example.com',
        'password' => 'secret123',
    ]);

    $response->assertStatus(422)
        ->assertJsonValidationErrors(['email']);
});

test('user can request login otp with email and correct password', function () {
    User::factory()->create([
        'email' => 'aniket.joshi@example.com',
        'password' => Hash::make('vedic123'),
    ]);

    $response = $this->postJson('/api/login/send-otp', [
        'email' => 'aniket.joshi@example.com',
        'password' => 'vedic123',
    ]);

    $response->assertStatus(200)
        ->assertJson([
            'success' => true,
            'email' => 'aniket.joshi@example.com',
        ]);

    $this->assertDatabaseHas('email_otps', [
        'email' => 'aniket.joshi@example.com',
        'type' => 'login',
    ]);
});

test('login with email and password directly returns sanctum token without otp', function () {
    $user = User::factory()->create([
        'name' => 'अनिकेत जोशी',
        'email' => 'aniket.joshi@example.com',
        'password' => Hash::make('vedic123'),
    ]);

    $response = $this->postJson('/api/login', [
        'email' => 'aniket.joshi@example.com',
        'password' => 'vedic123',
    ]);

    $response->assertStatus(200)
        ->assertJson([
            'success' => true,
            'token_type' => 'Bearer',
            'user' => [
                'id' => $user->id,
                'email' => 'aniket.joshi@example.com',
            ],
        ])
        ->assertJsonStructure(['token']);
});

test('login fails if identifier is not an email', function () {
    $response = $this->postJson('/api/login', [
        'email' => '9876543210',
        'password' => 'vedic123',
    ]);

    $response->assertStatus(422)
        ->assertJsonValidationErrors(['email']);
});

test('login fails with wrong password', function () {
    User::factory()->create([
        'email' => 'wrongpass@example.com',
        'password' => Hash::make('correct123'),
    ]);

    $response = $this->postJson('/api/login', [
        'email' => 'wrongpass@example.com',
        'password' => 'incorrectPassword',
    ]);

    $response->assertStatus(401)
        ->assertJson([
            'success' => false,
        ]);
});

test('unauthenticated users cannot access protected routes', function () {
    $this->getJson('/api/user')->assertStatus(401);
    $this->getJson('/api/cities?q=Pune')->assertStatus(401);
    $this->postJson('/api/calculate', [])->assertStatus(401);
    $this->postJson('/api/gunmilan', [])->assertStatus(401);
    $this->postJson('/api/download-pdf', [])->assertStatus(401);
    $this->postJson('/api/download-gunmilan-pdf', [])->assertStatus(401);
});

test('authenticated user can access profile with sanctum token', function () {
    $user = User::factory()->create([
        'name' => 'सुधाकर शास्त्री',
        'email' => 'shastri@example.com',
    ]);

    Sanctum::actingAs($user, ['*']);

    $response = $this->getJson('/api/user');

    $response->assertStatus(200)
        ->assertJson([
            'success' => true,
            'user' => [
                'id' => $user->id,
                'email' => 'shastri@example.com',
            ],
        ]);
});

test('authenticated user can logout and revoke token', function () {
    $user = User::factory()->create([
        'email' => 'logout_user@example.com',
        'password' => Hash::make('password123'),
    ]);

    $token = $user->createToken('test_token')->plainTextToken;

    $response = $this->withHeader('Authorization', "Bearer $token")
        ->postJson('/api/logout');

    $response->assertStatus(200)
        ->assertJson(['success' => true]);

    expect($user->tokens()->count())->toBe(0);
});

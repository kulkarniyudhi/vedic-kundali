<?php

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;

uses(RefreshDatabase::class);

beforeEach(function () {
    $user = User::factory()->create();
    Sanctum::actingAs($user, ['*']);
});

test('generates and downloads vedic kundali pdf', function () {
    // Generate valid kundali calculation data first
    $calcResponse = $this->postJson('/api/calculate', [
        'date' => '06-09-2000',
        'time' => '19:30:00',
        'lat' => 21.35,
        'lng' => 74.88,
        'place' => 'Shirpur',
    ]);

    $calcResponse->assertStatus(200);
    $data = $calcResponse->json();

    // Test form payload submission (POST with payload=json_string)
    $response = $this->post('/api/download-pdf', [
        'payload' => json_encode($data),
    ]);

    $response->assertStatus(200);
    expect($response->headers->get('content-type'))->toBe('application/pdf')
        ->and($response->headers->get('content-disposition'))->toContain('attachment')
        ->and(str_starts_with($response->getContent(), '%PDF-'))->toBeTrue();
});

test('generates and downloads gun milan pdf', function () {
    $calcResponse = $this->postJson('/api/gunmilan', [
        'boy' => [
            'name' => 'Ramesh',
            'date' => '06-09-2000',
            'time' => '19:30:00',
            'lat' => 21.35,
            'lng' => 74.88,
            'place' => 'Shirpur',
        ],
        'girl' => [
            'name' => 'Sita',
            'date' => '12-10-2001',
            'time' => '10:15:00',
            'lat' => 18.52,
            'lng' => 73.85,
            'place' => 'Pune',
        ],
    ]);

    $calcResponse->assertStatus(200);
    $data = $calcResponse->json();

    $response = $this->post('/api/download-gunmilan-pdf', [
        'payload' => json_encode($data),
    ]);

    $response->assertStatus(200);
    expect($response->headers->get('content-type'))->toBe('application/pdf')
        ->and($response->headers->get('content-disposition'))->toContain('gunmilan_Ramesh_Sita.pdf')
        ->and(str_starts_with($response->getContent(), '%PDF-'))->toBeTrue();
});

test('returns 400 when pdf payload is invalid or empty', function () {
    $response = $this->post('/api/download-pdf', []);
    $response->assertStatus(400);

    $gmResponse = $this->post('/api/download-gunmilan-pdf', []);
    $gmResponse->assertStatus(400);
});

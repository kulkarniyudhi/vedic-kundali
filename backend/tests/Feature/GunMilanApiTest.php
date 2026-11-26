<?php

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;

uses(RefreshDatabase::class);

beforeEach(function () {
    $user = User::factory()->create();
    Sanctum::actingAs($user, ['*']);
});

test('calculates gun milan successfully for boy and girl', function () {
    $payload = [
        'boy' => [
            'name' => 'युवक',
            'date' => '06-09-2000',
            'time' => '19:30:00',
            'lat' => 21.35,
            'lng' => 74.88,
            'place' => 'Shirpur',
            'state' => 'Maharashtra',
            'district' => 'Dhule',
        ],
        'girl' => [
            'name' => 'युवती',
            'date' => '12-10-2001',
            'time' => '10:15:00',
            'lat' => 18.52,
            'lng' => 73.85,
            'place' => 'Pune',
            'state' => 'Maharashtra',
            'district' => 'Pune',
        ],
        'ayanamsha' => 'lahiri',
    ];

    $response = $this->postJson('/api/gunmilan', $payload);

    $response->assertStatus(200)
        ->assertJsonStructure([
            'success',
            'engine',
            'boy',
            'girl',
            'gun_milan' => [
                'gunas',
                'total_max',
                'total_obtained',
                'percentage',
                'conclusion',
                'mangal_dosha',
            ],
            'mangal_dosha' => [
                'boy',
                'girl',
                'status',
                'summary',
                'is_samya',
                'is_clear',
            ],
        ]);

    expect($response->json('success'))->toBeTrue()
        ->and($response->json('gun_milan.total_max'))->toBe(36)
        ->and($response->json('gun_milan.total_obtained'))->toBeGreaterThanOrEqual(0)
        ->and(count($response->json('gun_milan.gunas')))->toBe(9);
});

test('fails validation when boy or girl details are missing', function () {
    $response = $this->postJson('/api/gunmilan', [
        'boy' => [
            'date' => '06-09-2000',
            'time' => '19:30:00',
            'lat' => 21.35,
            'lng' => 74.88,
        ],
    ]);

    $response->assertStatus(400)
        ->assertJson([
            'success' => false,
        ]);
});

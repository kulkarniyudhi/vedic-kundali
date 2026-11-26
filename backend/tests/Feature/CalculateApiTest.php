<?php

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;

uses(RefreshDatabase::class);

beforeEach(function () {
    $user = User::factory()->create();
    Sanctum::actingAs($user, ['*']);
});

test('calculates kundali successfully with valid birth details', function () {
    $payload = [
        'date' => '06-09-2000',
        'time' => '19:30:00',
        'lat' => 21.35,
        'lng' => 74.88,
        'place' => 'Shirpur',
        'state' => 'Maharashtra',
        'district' => 'Dhule',
        'tz_offset' => '+05:30',
        'ayanamsha' => 'lahiri',
    ];

    $response = $this->postJson('/api/calculate', $payload);

    $response->assertStatus(200)
        ->assertJsonStructure([
            'success',
            'engine',
            'birth_info' => [
                'date',
                'time',
                'day',
                'place',
                'state',
                'district',
                'coordinates',
                'lat',
                'lng',
                'timezone',
                'ishta_ghati',
            ],
            'ayanamsha' => [
                'value',
                'display',
                'system',
            ],
            'panchang' => [
                'tithi',
                'nakshatra',
                'yoga',
                'karana',
                'rashi',
            ],
            'hindu_calendar' => [
                'day_name',
                'hindu_month',
                'shaka_samvat',
                'vikram_kartik',
                'vikram_chaitra',
            ],
            'planet_details',
            'charts' => [
                'lagna',
                'navamsha',
                'chalit',
                'chandra',
            ],
            'mahadasha',
            'avakhada',
        ]);

    expect($response->json('success'))->toBeTrue()
        ->and($response->json('birth_info.place'))->toBe('Shirpur')
        ->and($response->json('ayanamsha.system'))->toBe('Lahiri')
        ->and($response->json('planet_details'))->toBeArray()
        ->and(count($response->json('mahadasha')))->toBe(9);
});

test('supports KP ayanamsha calculation', function () {
    $payload = [
        'date' => '06-09-2000',
        'time' => '19:30:00',
        'lat' => 21.35,
        'lng' => 74.88,
        'ayanamsha' => 'kp',
    ];

    $response = $this->postJson('/api/calculate', $payload);

    $response->assertStatus(200)
        ->assertJsonPath('ayanamsha.system', 'KP');
});

test('fails validation when required fields are missing', function () {
    $response = $this->postJson('/api/calculate', [
        'date' => '06-09-2000',
    ]);

    $response->assertStatus(400)
        ->assertJson([
            'success' => false,
        ]);
});

test('fails validation for invalid date format', function () {
    $response = $this->postJson('/api/calculate', [
        'date' => 'invalid-date',
        'time' => '12:00:00',
        'lat' => 18.52,
        'lng' => 73.85,
    ]);

    $response->assertStatus(400)
        ->assertJson([
            'success' => false,
        ]);
});

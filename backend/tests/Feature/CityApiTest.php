<?php

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;

uses(RefreshDatabase::class);

beforeEach(function () {
    $user = User::factory()->create();
    Sanctum::actingAs($user, ['*']);
});

test('searches cities by query string', function () {
    $response = $this->getJson('/api/cities?q=shir');

    $response->assertStatus(200)
        ->assertJsonStructure([
            'results' => [
                '*' => [
                    'name',
                    'state',
                    'district',
                    'lat',
                    'lng',
                    'tz',
                    'display',
                ],
            ],
        ]);

    $results = $response->json('results');
    expect(count($results))->toBeGreaterThan(0);

    $names = array_column($results, 'name');
    expect(in_array('Shirpur', $names, true) || in_array('shirpur', array_map('strtolower', $names), true))->toBeTrue();
});

test('returns error when query is less than 2 characters', function () {
    $response = $this->getJson('/api/cities?q=a');

    $response->assertStatus(200)
        ->assertJson([
            'results' => [],
            'error' => 'Query must be at least 2 characters',
        ]);
});

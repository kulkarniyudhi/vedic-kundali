<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    use WithoutModelEvents;

    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // User::factory(10)->create();

        User::updateOrCreate(
            ['email' => 'aniket.joshi@example.com'],
            [
                'name' => 'अनिकेत जोशी',
                'phone' => '9876543210',
                'password' => \Illuminate\Support\Facades\Hash::make('vedic123'),
            ]
        );
    }
}

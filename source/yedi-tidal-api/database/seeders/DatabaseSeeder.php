<?php

namespace Database\Seeders;

use App\Enums\UserTitle;
use App\Enums\UserType;
use App\Models\User;
use Carbon\Carbon;
// use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        // User::factory(10)->create();

        User::factory()->create([
            'first_name' => 'Admin',
            'last_name' => 'User',
            'title' => UserTitle::Mr,
            'email' => 'admin@example.com',
            'password' => 'password',
            'type' => UserType::Admin,
            'date_of_birth' => Carbon::now(),
            'telephone' => '01911231233',
        ]);
        User::factory()->create([
            'first_name' => 'Applicant',
            'last_name' => 'User',
            'title' => UserTitle::Mr,
            'email' => 'applicant@example.com',
            'password' => 'password',
            'type' => UserType::Applicant,
            'date_of_birth' => Carbon::now(),
            'telephone' => '01911231233',
        ]);
    }
}

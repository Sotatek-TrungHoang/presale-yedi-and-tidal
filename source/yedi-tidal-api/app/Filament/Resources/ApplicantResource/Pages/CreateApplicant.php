<?php

namespace App\Filament\Resources\ApplicantResource\Pages;

use App\Enums\ApplicantComplianceStatus;
use App\Enums\ProfileStatus;
use App\Enums\UserTitle;
use App\Enums\UserType;
use App\Filament\Resources\ApplicantResource;
use App\Models\Applicant;
use App\Models\User;
use Faker\Generator as Faker;
use Filament\Forms\Components\Actions;
use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\Section;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Resources\Pages\CreateRecord;
use Illuminate\Support\Facades\DB;

class CreateApplicant extends CreateRecord
{
    protected static string $resource = ApplicantResource::class;

    protected function handleRecordCreation(array $data): Applicant
    {
        try {
            DB::beginTransaction();
            $user = new User([
                ...$data,
                'type' => UserType::Applicant,
            ]);
            $applicant = new Applicant([
                'profile_status' => ProfileStatus::Incomplete,
                'compliance_status' => ApplicantComplianceStatus::Incomplete,
            ]);
            $applicant->save();
            $user->userable()->associate($applicant);
            $user->save();
            DB::commit();

            return $applicant;
        } catch (\Throwable $th) {
            DB::rollBack();
            throw $th;
        }

    }

    public static function getCreateSchema()
    {
        return [
            Section::make(___('applicant').' Details')
                ->columns(3)->schema([
                    Select::make('title')
                        ->required()
                        ->options(UserTitle::class),
                    TextInput::make('first_name')
                        ->required(),
                    TextInput::make('last_name')
                        ->required(),
                    TextInput::make('email')
                        ->email()
                        ->unique('users')
                        ->required(),
                    TextInput::make('telephone')
                        ->required()
                        ->tel(),
                    DatePicker::make('date_of_birth')
                        ->required(),
                    TextInput::make('password')
                        ->required()
                        ->password(),
                ]),
            Actions::make([
                Actions\Action::make('fill')
                    ->icon('heroicon-m-star')
                    ->action(function ($livewire, Faker $faker) {
                        $livewire->form->fill([
                            'title' => $faker->randomElement(UserTitle::class),
                            'first_name' => $faker->firstName,
                            'last_name' => $faker->lastName,
                            'email' => $faker->email,
                            'telephone' => $faker->phoneNumber(),
                            'password' => 'password',
                            'date_of_birth' => $faker->dateTimeBetween('-60 years', '-20 years')->format('Y-m-d H:i:s'),
                        ]);
                    }),
            ])->visible(fn () => app()->environment('local') ? true : false),
        ];
    }
}

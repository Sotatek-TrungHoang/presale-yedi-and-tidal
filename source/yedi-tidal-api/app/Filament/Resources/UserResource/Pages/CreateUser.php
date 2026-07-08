<?php

namespace App\Filament\Resources\UserResource\Pages;

use App\Enums\UserType;
use App\Filament\Resources\UserResource;
use App\Models\User;
use Filament\Resources\Pages\CreateRecord;

class CreateUser extends CreateRecord
{
    protected static string $resource = UserResource::class;

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('index');
    }

    protected function handleRecordCreation(array $data): User
    {
        $user = User::create([
            ...$data,
            'type' => UserType::Admin,
            'telephone' => '',
        ]);

        return $user;
    }
}

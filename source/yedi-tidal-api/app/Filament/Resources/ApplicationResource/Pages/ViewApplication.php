<?php

namespace App\Filament\Resources\ApplicationResource\Pages;

use App\Enums\ApplicationStatus;
use App\Filament\Resources\ApplicationResource;
use App\Models\Application;
use Filament\Actions\Action;
use Filament\Actions\DeleteAction;
use Filament\Forms\Components\DateTimePicker;
use Filament\Forms\Components\Select;
use Filament\Resources\Pages\ViewRecord;

class ViewApplication extends ViewRecord
{
    protected static string $resource = ApplicationResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Action::make('Update Status')->form([
                Select::make('status')
                    ->formatStateUsing(callback: fn ($record) => $record->status)
                    ->options(ApplicationStatus::class)
                    ->required(),
                DateTimePicker::make('actioned_at')
                    ->formatStateUsing(callback: fn ($record) => $record->actioned_at),
            ])
                ->action(fn (Application $record, array $data) => $record
                    ->update([
                        'status' => $data['status'],
                        'actioned_at' => $data['actioned_at'],
                    ])),
            DeleteAction::make(),

        ];
    }
}

<?php

namespace App\Filament\Resources\ApplicantResource\RelationManagers;

use App\Filament\Resources\ApplicationResource;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables;
use Filament\Tables\Table;

class ApplicationsRelationManager extends RelationManager
{
    protected static string $relationship = 'applications';

    public function isReadOnly(): bool
    {
        return false;
    }

    public function table(Table $table): Table
    {
        return $table
            ->emptyStateDescription('')
            ->recordUrl(url: fn ($record) => ApplicationResource::geturl('view', [$record]))
            ->recordTitleAttribute('id')
            ->columns([
                Tables\Columns\TextColumn::make('advert.title')->label(___('advert')),
                Tables\Columns\TextColumn::make('status')->badge(),
            ])
            ->filters([
                //
            ])
            ->headerActions([
                Tables\Actions\CreateAction::make()
                    ->url(fn ($livewire) => ApplicationResource::getUrl('create', ['applicant_id' => $livewire->ownerRecord->getKey()])),
            ])
            ->actions([
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }
}

<?php

namespace App\Filament\Resources\AdvertiserResource\Pages;

use App\Enums\AdvertiserComplianceStatus;
use App\Filament\Resources\AdvertiserResource;
use Filament\Actions;
use Filament\Resources\Components\Tab;
use Filament\Resources\Pages\ListRecords;
use Filament\Tables\Actions\BulkActionGroup;
use Filament\Tables\Actions\DeleteBulkAction;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class ListAdvertisers extends ListRecords
{
    protected static string $resource = AdvertiserResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }

    public function getTabs(): array
    {
        return [
            'all' => Tab::make(),
            'compliant' => Tab::make()
                ->modifyQueryUsing(fn (Builder $query) => $query->where('compliance_status', AdvertiserComplianceStatus::Compliant)),
            'Non-Compliant' => Tab::make()
                ->modifyQueryUsing(fn (Builder $query) => $query->where('compliance_status', AdvertiserComplianceStatus::NonCompliant)),
            'Pending' => Tab::make()
                ->modifyQueryUsing(fn (Builder $query) => $query->where('compliance_status', AdvertiserComplianceStatus::Pending)),
        ];
    }

    public static function getResourceTable(Table $table)
    {
        return $table
            ->columns([
                TextColumn::make('profile_status')
                    ->label('Status')
                    ->badge(),
                TextColumn::make('compliance_status')
                    ->label('Compliance')
                    ->badge(),
                TextColumn::make('name')
                    ->sortable()
                    ->searchable(),
                TextColumn::make('adverts_count')
                    ->label(___('adverts'))
                    ->counts('adverts')
                    ->sortable(),
                TextColumn::make('email')
                    ->searchable(),
                TextColumn::make('telephone')
                    ->searchable(),
                TextColumn::make('created_at')
                    ->label('Date Joined')
                    ->date()
                    ->sortable(),
                TextColumn::make('updated_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
                TextColumn::make('deleted_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([])
            ->actions([])
            ->bulkActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ]);
    }
}

<?php

namespace App\Filament\Resources\AdvertiserResource\RelationManagers;

use App\Enums\AdvertStatus;
use App\Enums\AdvertType;
use App\Filament\Resources\AdvertResource;
use Filament\Resources\Components\Tab;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Model;

class AdvertsRelationManager extends RelationManager
{
    protected static string $relationship = 'adverts';

    public function isReadOnly(): bool
    {
        return false;
    }

    public static function getTitle(Model $ownerRecord, string $pageClass): string
    {
        return ___('advert');
    }

    public function getTabs(): array
    {

        return [
            'all' => Tab::make(),
            'day_to_day' => Tab::make()
                ->modifyQueryUsing(fn (Builder $query) => $query->where('type', AdvertType::DayToDay)),
            'long_term' => Tab::make()
                ->modifyQueryUsing(fn (Builder $query) => $query->where('type', AdvertType::LongTerm)),
            'approved' => Tab::make()
                ->modifyQueryUsing(fn (Builder $query) => $query->where('status', AdvertStatus::Approved)),
            'pending_approval' => Tab::make()
                ->modifyQueryUsing(fn (Builder $query) => $query->where('status', AdvertStatus::PendingApproval)),
            'not_filled' => Tab::make()
                ->modifyQueryUsing(fn (Builder $query) => $query->where('status', AdvertStatus::NotFilled)),
            'filled' => Tab::make()
                ->modifyQueryUsing(fn (Builder $query) => $query->where('status', AdvertStatus::Filled)),
            'pending_allocation' => Tab::make()
                ->modifyQueryUsing(fn (Builder $query) => $query->where('status', AdvertStatus::PendingAllocation)),
            'rejected' => Tab::make()
                ->modifyQueryUsing(fn (Builder $query) => $query->where('status', AdvertStatus::Rejected)),
        ];
    }

    public function table(Table $table): Table
    {
        return $table
            ->modelLabel(___('advert'))
            ->recordUrl(url: fn ($record) => AdvertResource::geturl('view', [$record]))
            ->recordTitleAttribute('title')
            ->columns([
                Tables\Columns\TextColumn::make('title'),
                Tables\Columns\TextColumn::make('type')->badge(),
                Tables\Columns\TextColumn::make('status')->badge(),
                Tables\Columns\TextColumn::make('starts_at')
                    ->date()
                    ->sortable(),
                Tables\Columns\TextColumn::make('ends_at')
                    ->date()
                    ->sortable(),
                Tables\Columns\TextColumn::make('apply_by')
                    ->date()
                    ->sortable(),
            ])
            ->filters([])
            ->recordAction(null)
            ->headerActions(
                [
                    Tables\Actions\CreateAction::make()
                        ->url(fn ($livewire) => AdvertResource::getUrl('create', ['advertiser_id' => $livewire->ownerRecord->getKey()])),

                ])
            ->actions([])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }
}

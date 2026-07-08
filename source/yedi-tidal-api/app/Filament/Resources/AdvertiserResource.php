<?php

namespace App\Filament\Resources;

use App\Enums\ProfileStatus;
use App\Filament\Resources\AdvertiserResource\Pages;
use App\Filament\Resources\AdvertiserResource\Pages\EditAdvertiser;
use App\Filament\Resources\AdvertiserResource\Pages\ListAdvertisers;
use App\Filament\Resources\AdvertiserResource\Pages\ViewAdvertiser;
use App\Filament\Resources\AdvertiserResource\RelationManagers\AdvertsRelationManager;
use App\Models\Advertiser;
use Filament\Forms\Form;
use Filament\Infolists\Infolist;
use Filament\Resources\Resource;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Model;

class AdvertiserResource extends Resource
{
    protected static ?string $model = Advertiser::class;

    protected static ?int $navigationSort = 10;

    public static function getNavigationIcon(): string
    {
        return ___('advertiser-icon');
    }

    public static function getLabel(): string
    {
        return ___('advertiser');
    }

    public static function canEdit(Model $record): bool
    {
        return $record->profile_status !== ProfileStatus::Incomplete;
    }

    public static function form(Form $form): Form
    {
        return $form->schema(EditAdvertiser::getEditFormSchema());
    }

    public static function table(Table $table): Table
    {
        return ListAdvertisers::getResourceTable($table);
    }

    public static function Infolist(Infolist $infolist): Infolist
    {
        return ViewAdvertiser::getResourceInfolist($infolist);
    }

    public static function getRelations(): array
    {
        return [
            AdvertsRelationManager::class,
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListAdvertisers::route('/'),
            'create' => Pages\CreateAdvertiser::route('/create'),
            'view' => Pages\ViewAdvertiser::route('/{record}'),
            'edit' => Pages\EditAdvertiser::route('/{record}/edit'),
        ];
    }

    // GLOBAL search setup

    protected static ?string $recordTitleAttribute = 'name';

    public static function getGloballySearchableAttributes(): array
    {
        return ['name', 'email', 'user.name', 'user.email', 'address.line_1', 'address.town_city', 'address.postcode'];
    }

    public static function getGlobalSearchResultUrl(Model $record): string
    {
        return AdvertiserResource::getUrl('view', ['record' => $record]);
    }

    public static function getGlobalSearchResultDetails(Model $record): array
    {
        return [
            'Address' => $record->address?->formatted,
        ];
    }
}

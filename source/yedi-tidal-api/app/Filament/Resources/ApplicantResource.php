<?php

namespace App\Filament\Resources;

use App\Enums\ProfileStatus;
use App\Filament\Resources\ApplicantResource\Pages;
use App\Filament\Resources\ApplicantResource\Pages\CreateApplicant;
use App\Filament\Resources\ApplicantResource\Pages\EditApplicant;
use App\Filament\Resources\ApplicantResource\Pages\ListApplicants;
use App\Filament\Resources\ApplicantResource\Pages\ViewApplicant;
use App\Filament\Resources\ApplicantResource\RelationManagers\ApplicationsRelationManager;
use App\Models\Applicant;
use Filament\Forms\Form;
use Filament\Infolists\Infolist;
use Filament\Resources\Pages\CreateRecord;
use Filament\Resources\Resource;
use Filament\Tables\Actions\BulkActionGroup;
use Filament\Tables\Actions\DeleteBulkAction;
use Filament\Tables\Table;
use Illuminate\Contracts\Support\Htmlable;
use Illuminate\Database\Eloquent\Model;

class ApplicantResource extends Resource
{
    protected static ?string $model = Applicant::class;

    protected static ?string $navigationIcon = 'heroicon-o-user-group';

    protected static ?int $navigationSort = 30;

    // name the resource based on the translation
    public static function getLabel(): string
    {
        return ___('applicant');
    }

    public static function canEdit(Model $record): bool
    {
        return $record->profile_status !== ProfileStatus::Incomplete;
    }

    // form changes depending on create or edit
    public static function form(Form $form): Form
    {
        return $form
            ->schema(fn ($livewire) => $livewire instanceof CreateRecord
                ? CreateApplicant::getCreateSchema()
                : EditApplicant::getEditSchema());
    }

    public static function infolist(Infolist $infolist): Infolist
    {
        return $infolist->schema(ViewApplicant::getInfoSchema());
    }

    public static function table(Table $table): Table
    {
        return $table->columns(ListApplicants::getTableSchema())
            ->filters([])
            ->actions([])
            ->bulkActions([
                BulkActionGroup::make([
                    DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getRelations(): array
    {
        return [
            ApplicationsRelationManager::class,
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListApplicants::route('/'),
            'create' => Pages\CreateApplicant::route('/create'),
            'edit' => Pages\EditApplicant::route('/{record}/edit'),
            'view' => Pages\ViewApplicant::route('/{record}/view'),
        ];
    }

    // GLOBAL search setup
    protected static ?string $recordTitleAttribute = 'user.name';

    public static function getGlobalSearchResultTitle(Model $record): string|Htmlable
    {
        return $record->user->name;
    }

    public static function getGloballySearchableAttributes(): array
    {
        return ['user.name', 'user.email', 'address.line_1', 'address.town_city', 'address.postcode'];
    }

    public static function getGlobalSearchResultUrl(Model $record): string
    {
        return ApplicantResource::getUrl('view', ['record' => $record]);
    }
}

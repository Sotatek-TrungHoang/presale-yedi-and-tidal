<?php

namespace App\Filament\Resources\AdvertResource\RelationManagers;

use App\Enums\ApplicationStatus;
use App\Filament\Resources\ApplicationResource;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Components\Tab;
use Filament\Resources\RelationManagers\RelationManager;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Builder;

class ApplicantsRelationManager extends RelationManager
{
    protected static string $relationship = 'applications';

    public function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\TextInput::make('title')
                    ->required()
                    ->maxLength(255),
            ]);
    }

    public function getTabs(): array
    {
        return [
            'all' => Tab::make(),
            'accepted' => Tab::make()->modifyQueryUsing(fn (Builder $query) => $query->where('status', ApplicationStatus::Accepted)),
            'cancelled' => Tab::make()->modifyQueryUsing(fn (Builder $query) => $query->where('status', ApplicationStatus::Cancelled)),
            'declined' => Tab::make()->modifyQueryUsing(fn (Builder $query) => $query->where('status', ApplicationStatus::Declined)),
            'pending' => Tab::make()->modifyQueryUsing(fn (Builder $query) => $query->where('status', ApplicationStatus::Pending)),
        ];
    }

    public function table(Table $table): Table
    {
        return $table
            ->recordTitleAttribute('status')
            ->recordUrl(url: fn ($record) => ApplicationResource::geturl('view', [$record]))
            ->columns([
                Tables\Columns\TextColumn::make('status')->badge()->width(0),
                Tables\Columns\TextColumn::make('applicant.user.name'),
            ])
            ->filters([
                //
            ])
            ->headerActions([
                Tables\Actions\CreateAction::make(),
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
                Tables\Actions\DeleteAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }
}

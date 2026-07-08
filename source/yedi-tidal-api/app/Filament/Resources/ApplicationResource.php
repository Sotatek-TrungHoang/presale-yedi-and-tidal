<?php

namespace App\Filament\Resources;

use App\Enums\ApplicationStatus;
use App\Filament\Resources\ApplicationResource\Pages;
use App\Models\Advert;
use App\Models\Applicant;
use App\Models\Application;
use Faker\Generator as Faker;
use Filament\Forms;
use Filament\Forms\Components\Actions;
use Filament\Forms\Form;
use Filament\Infolists\Components\Section;
use Filament\Infolists\Components\TextEntry;
use Filament\Infolists\Infolist;
use Filament\Resources\Resource;
use Filament\Support\Enums\IconPosition;
use Filament\Tables;
use Filament\Tables\Table;

class ApplicationResource extends Resource
{
    protected static ?string $model = Application::class;

    protected static ?int $navigationSort = 40;

    protected static ?string $navigationIcon = 'heroicon-o-inbox-stack';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\Section::make('Application Details')
                    ->columns(3)->schema([
                        Forms\Components\Select::make('applicant_id')
                            ->label(___('applicant'))
                            ->options(Applicant::all()->pluck('user.name', 'id'))
                            // pull data from request if coming from applicant page
                            ->default(request()->query('applicant_id'))
                            ->required(),
                        Forms\Components\Select::make('advert_id')
                            ->required()
                            ->label(___('advert'))
                            ->relationship('advert', 'title'),
                        Forms\Components\Select::make('status')
                            ->options(ApplicationStatus::class)
                            ->required(),
                        Forms\Components\DateTimePicker::make('actioned_at'),
                    ]),

                Actions::make([
                    Actions\Action::make('fill')
                        ->icon('heroicon-m-star')
                        ->action(function ($livewire, Faker $faker) {
                            $livewire->form->fill([
                                'applicant_id' => $faker->randomElement(Applicant::all())->id,
                                'advert_id' => $faker->randomElement(Advert::all())->id,
                                'status' => $faker->randomElement(ApplicationStatus::class),
                                'actioned_at' => $faker->dateTimeBetween('-1 month', 'yesterday')->format('Y-m-d H:i:s'),
                            ]);
                        }),
                ])->visible(fn () => app()->environment('local') ? true : false),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('applicant.user.name')
                    ->label(___('applicant'))
                    ->sortable(),
                Tables\Columns\TextColumn::make('advert.title')
                    ->label(___('advert'))
                    ->sortable(),
                Tables\Columns\TextColumn::make('status')
                    ->searchable(),
                Tables\Columns\TextColumn::make('actioned_at')
                    ->searchable(),
                Tables\Columns\TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
                Tables\Columns\TextColumn::make('updated_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
                Tables\Columns\TextColumn::make('deleted_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
            ])
            ->filters([])
            ->actions([])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function infolist(Infolist $infolist): Infolist
    {
        return $infolist->schema([
            Section::make('Details')->columns(4)
                ->schema([
                    TextEntry::make('status')->badge(),
                    TextEntry::make('applicant.user.name')->label(___('applicant').' name'),
                    TextEntry::make('advert.title')->label(___('advert')),
                    TextEntry::make('rating')->icon('heroicon-m-star')->iconPosition(IconPosition::After),
                    TextEntry::make('actioned_at')->dateTime(),
                ]),
        ]);
    }

    public static function getRelations(): array
    {
        return [];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListApplications::route('/'),
            'create' => Pages\CreateApplication::route('/create'),
            'edit' => Pages\EditApplication::route('/{record}/edit'),
            'view' => Pages\ViewApplication::route('/{record}/view'),
        ];
    }
}

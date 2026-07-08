<?php

namespace App\Filament\Resources;

use App\Filament\Resources\AddressResource\Pages;
use App\Models\Address;
use Faker\Generator as Faker;
use Filament\Forms;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use League\ISO3166\ISO3166;

class AddressResource extends Resource
{
    protected static ?string $model = Address::class;

    protected static ?string $navigationIcon = 'heroicon-o-rectangle-stack';

    public static function canAccess(): bool
    {
        return false;
    }

    public static function getFormSchema(): array
    {
        return [
            Forms\Components\TextInput::make('line_1')
                ->required()
                ->maxLength(255),
            Forms\Components\TextInput::make('line_2')
                ->maxLength(255),
            Forms\Components\TextInput::make('town_city')
                ->required()
                ->maxLength(255),
            Forms\Components\TextInput::make('postcode')
                ->required()
                ->maxLength(255),
            Forms\Components\Select::make('country.alpha2')
                ->label('Country')
                ->required()
                ->searchable()
                ->optionsLimit(300)
                ->options(collect((new ISO3166)->all())->pluck('name', 'alpha2')),
            Forms\Components\Actions::make([
                Forms\Components\Actions\Action::make('Fill')
                    ->icon('heroicon-m-star')
                    ->action(function ($livewire, Faker $faker) {
                        $formIdx = array_search('data.address_id', $livewire->mountedFormComponentActionsComponents);

                        $livewire->mountedFormComponentActionsData[$formIdx] = [
                            'line_1' => $faker->streetAddress,
                            'line_2' => $faker->streetName,
                            'town_city' => $faker->city,
                            'postcode' => $faker->postcode,
                            'country' => $faker->randomElement((new ISO3166)->all()),
                        ];
                    }),
            ])->visible(fn () => app()->environment('local') ? true : false),
        ];
    }

    public static function form(Form $form): Form
    {

        return $form
            ->schema(self::getFormSchema());
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('owner_type')
                    ->getStateUsing(function ($record) {
                        return ___(strtolower(class_basename($record->owner)));
                    })
                    ->searchable(),
                Tables\Columns\TextColumn::make('owner')
                    ->getStateUsing(function ($record) {
                        return $record->owner->user->name;
                    })
                    ->sortable(),
                Tables\Columns\TextColumn::make('line_1')
                    ->searchable(),
                Tables\Columns\TextColumn::make('line_2')
                    ->searchable(),
                Tables\Columns\TextColumn::make('town_city')
                    ->searchable(),
                Tables\Columns\TextColumn::make('postcode')
                    ->searchable(),
                Tables\Columns\TextColumn::make('country.alpha2')
                    ->searchable(),
            ])
            ->filters([
                //
            ])
            ->actions([
                Tables\Actions\EditAction::make(),
            ])
            ->bulkActions([
                Tables\Actions\BulkActionGroup::make([
                    Tables\Actions\DeleteBulkAction::make(),
                ]),
            ]);
    }

    public static function getRelations(): array
    {
        return [
            //
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListAddresses::route('/'),
            'create' => Pages\CreateAddress::route('/create'),
            'edit' => Pages\EditAddress::route('/{record}/edit'),
        ];
    }
}

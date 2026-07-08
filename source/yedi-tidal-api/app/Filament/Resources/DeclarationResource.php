<?php

namespace App\Filament\Resources;

use App\Filament\Resources\DeclarationResource\Pages;
use App\Handlers\Uploads\UploadFileHandler;
use App\Models\Declaration;
use App\Models\Upload;
use Faker\Generator as Faker;
use Filament\Forms;
use Filament\Forms\Components\Actions;
use Filament\Forms\Components\Actions\Action;
use Filament\Forms\Form;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;

class DeclarationResource extends Resource
{
    protected static ?string $model = Declaration::class;

    protected static ?string $navigationGroup = 'Settings';

    protected static ?string $navigationIcon = 'heroicon-o-swatch';

    public static function form(Form $form): Form
    {
        return $form
            ->schema([
                Forms\Components\TextInput::make('title')
                    ->required()
                    ->maxLength(255),
                Forms\Components\Textarea::make('description')
                    ->required()
                    ->columnSpanFull(),
                Forms\Components\TextInput::make('time_to_complete')
                    ->required()
                    ->maxLength(255),
                Forms\Components\FileUpload::make('upload_id')
                    ->label('Upload')
                    ->fetchFileInformation(false)
                    ->openable()
                    ->required()
                    ->getUploadedFileUsing(function (string $file) {
                        $url = Upload::query()->find($file)->url;

                        return ['url' => $url];
                    })
                    ->saveUploadedFileUsing(function ($file, UploadFileHandler $uploadFileHandler, $record) {
                        $upload = $uploadFileHandler->handle($file);
                        if ($record) {
                            $upload->owner()->associate($record)->save();
                        }

                        return strval($upload->id);
                    }),
                Forms\Components\Toggle::make('required'),

                Actions::make([
                    Action::make('fill')
                        ->icon('heroicon-m-star')
                        ->action(function ($livewire, Faker $faker) {
                            $livewire->form->fill([
                                'title' => $faker->words(asText: true),
                                'description' => $faker->sentences(asText: true),
                                'time_to_complete' => '10 mins',
                            ]);
                        }),
                ])->columnStart(1)->visible(fn () => app()->environment('local') ? true : false),
            ]);
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('title')
                    ->searchable(),
                Tables\Columns\TextColumn::make('time_to_complete')
                    ->searchable(),
                Tables\Columns\TextColumn::make('upload_id')
                    ->label('Upload')
                    ->state('Link')
                    ->url(function ($record) {
                        if (! $record->upload_id) {
                            return null;
                        }

                        return Upload::query()->find($record->upload_id)->url;
                    })
                    ->openUrlInNewTab(),
                Tables\Columns\IconColumn::make('required')
                    ->boolean(),
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
        return [];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListDeclarations::route('/'),
            'create' => Pages\CreateDeclaration::route('/create'),
            'edit' => Pages\EditDeclaration::route('/{record}/edit'),
        ];
    }
}

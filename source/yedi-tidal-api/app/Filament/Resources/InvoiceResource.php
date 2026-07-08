<?php

namespace App\Filament\Resources;

use App\Filament\Resources\InvoiceResource\Pages;
use App\Models\Invoice;
use App\Models\Upload;
use Filament\Actions\Action;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Model;

class InvoiceResource extends Resource
{
    protected static ?string $model = Invoice::class;

    protected static ?string $navigationIcon = 'heroicon-o-document-currency-pound';

    protected static ?int $navigationSort = 70;

    public static function canCreate(): bool
    {
        return false;
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('invoice_number')
                    ->searchable(),
                Tables\Columns\TextColumn::make('title')
                    ->sortable()
                    ->searchable(),
                Tables\Columns\TextColumn::make('advert.title')
                    ->label(___('advert'))
                    ->sortable()
                    ->url(function ($record) {
                        if (! $record->advert) {
                            return null;
                        }

                        return AdvertResource::getUrl('view', [$record->advert]);
                    }),
                Tables\Columns\TextColumn::make('upload_id')
                    ->label('Invoice')
                    ->icon('heroicon-o-arrow-down-tray')
                    ->state('Download')
                    ->url(function ($record) {
                        if (! $record->upload_id) {
                            return null;
                        }

                        return Upload::query()->find($record->upload_id)->url;
                    })
                    ->openUrlInNewTab(),
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
            ->headerActions([])
            ->filters([])
            ->actions([])
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
            'index' => Pages\ListInvoices::route('/'),
        ];
    }

    // GLOBAL search setup

    protected static ?string $recordTitleAttribute = 'invoice_number';

    public static function getGloballySearchableAttributes(): array
    {
        return ['invoice_number', 'title', 'advert.title', 'advert.advertiser.name'];
    }

    public static function getGlobalSearchResultDetails(Model $record): array
    {
        return [
            ___('advertiser') => $record->advert->advertiser->name,
            ___('advert') => $record->advert->title,
        ];
    }

    public static function getGlobalSearchResultActions(Model $record): array
    {
        return [
            Action::make('upload_id')
                ->label('Download')
                ->icon('heroicon-o-arrow-down-tray')
                ->url(function () use ($record) {
                    return Upload::query()->find($record->upload_id)->url;
                })
                ->openUrlInNewTab(),
        ];

    }
}

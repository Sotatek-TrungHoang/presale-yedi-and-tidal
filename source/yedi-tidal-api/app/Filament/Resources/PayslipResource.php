<?php

namespace App\Filament\Resources;

use App\Filament\Resources\PayslipResource\Pages;
use App\Models\Payslip;
use App\Models\Upload;
use Filament\Actions\Action;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Table;
use Illuminate\Database\Eloquent\Model;

class PayslipResource extends Resource
{
    protected static ?string $model = Payslip::class;

    protected static ?string $navigationIcon = 'heroicon-o-credit-card';

    protected static ?int $navigationSort = 70;

    public static function canCreate(): bool
    {
        return false;
    }

    public static function table(Table $table): Table
    {
        return $table
            ->columns([
                Tables\Columns\TextColumn::make('payslip_number')
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
                Tables\Columns\TextColumn::make('applicant.user.name')
                    ->label(___('applicant'))
                    ->sortable()
                    ->url(function ($record) {
                        if (! $record) {
                            return null;
                        }

                        return ApplicantResource::getUrl('view', [$record->id]);
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
            'index' => Pages\ListPayslips::route('/'),
        ];
    }

    // GLOBAL search setup

    protected static ?string $recordTitleAttribute = 'payslip_number';

    public static function getGloballySearchableAttributes(): array
    {
        return ['payslip_number', 'title', 'advert.title', 'advert.advertiser.name', 'applicant.teacher_number', 'applicant.user.name'];
    }

    public static function getGlobalSearchResultDetails(Model $record): array
    {
        return [
            ___('applicant') => $record->applicant->user->name,
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

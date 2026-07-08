<?php

namespace App\Filament\Resources\AdvertResource\Pages;

use App\Enums\AdvertStatus;
use App\Filament\Resources\AdvertiserResource;
use App\Filament\Resources\AdvertResource;
use App\Models\Advert;
use App\Models\Upload;
use Filament\Actions\Action;
use Filament\Actions\DeleteAction;
use Filament\Actions\EditAction;
use Filament\Forms\Components\Select;
use Filament\Infolists\Components\Fieldset;
use Filament\Infolists\Components\RepeatableEntry;
use Filament\Infolists\Components\Section;
use Filament\Infolists\Components\TextEntry;
use Filament\Resources\Pages\ViewRecord;

class ViewAdvert extends ViewRecord
{
    protected static string $resource = AdvertResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Action::make('Update Status')
                ->form([
                    Select::make('status')
                        ->formatStateUsing(callback: fn ($record) => $record->status)
                        ->options(AdvertStatus::class)
                        ->required(),
                ])
                ->action(fn ($data, Advert $record) => $record
                    ->update(['status' => $data['status']])),
            EditAction::make(),
            DeleteAction::make(),
        ];
    }

    public static function getInfoSchema(): array
    {

        return [
            Section::make(heading: ___('advert').' Details')->columns(4)->schema([
                TextEntry::make('title'),
                TextEntry::make('advertiser.name')
                    ->url(fn ($record) => AdvertiserResource::getUrl('view', ['record' => $record->id]))
                    ->label(___(key: 'advertiser')),
                TextEntry::make('type')->badge(),
                TextEntry::make('status')->badge(),

                TextEntry::make('acceptedApplication.applicant.user.name'),

                Fieldset::make('Address')
                    ->columnSpanFull()
                    ->columns(4)
                    ->visible(function ($record) {
                        return (bool) $record->address;
                    })
                    ->schema([
                        TextEntry::make('address.line_1')->label('Line 1'),
                        TextEntry::make('address.line_2')->label('Line 2'),
                        TextEntry::make('address.town_city')->label('Town/City'),
                        TextEntry::make('address.postcode')->label('Postcode'),
                        TextEntry::make('address.country.name')->label('Country'),
                    ]),

                Fieldset::make('Date')->columnSpan(2)->schema([
                    TextEntry::make('starts_at')->date(),
                    TextEntry::make('ends_at')->date(),
                ]),

                Fieldset::make('Shift')->columnSpan(2)->schema([
                    TextEntry::make('shift_start_time')
                        ->label('Start time'),
                    TextEntry::make('shift_end_time')
                        ->label('End time'),
                ]),

                TextEntry::make('apply_by')->date(),
                TextEntry::make('description')->columnSpanFull(),

            ]),

            Section::make(heading: 'Documents')->columns(4)->schema([
                RepeatableEntry::make('documents')
                    ->hiddenLabel()
                    ->columnSpanFull()
                    ->schema([
                        TextEntry::make('title'),
                        TextEntry::make('upload_id')
                            ->label('Upload')
                            ->state('Link')
                            ->url(function ($record) {
                                return Upload::find($record->upload_id)->url;
                            })
                            ->openUrlInNewTab(),
                    ])
                    ->columns(2),
            ]),

            Section::make(heading: 'Payment & Charges')->columns(4)->schema([
                TextEntry::make('advertiser_pay_rate')
                    ->label(___('advertiser').' Pay Rate'),
                TextEntry::make('advertiser_pay_rate_type')
                    ->label(___('advertiser').' Pay Rate Type')
                    ->badge(),
                TextEntry::make('advertiser_charge_percentage')
                    ->label(___('advertiser').' Charge %'),
                TextEntry::make('applicant_charge_percentage')
                    ->label(___('applicant').' Charge %'),

            ]),
        ];
    }
}

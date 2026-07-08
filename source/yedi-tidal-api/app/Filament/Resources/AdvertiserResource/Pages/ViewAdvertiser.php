<?php

namespace App\Filament\Resources\AdvertiserResource\Pages;

use App\Enums\AdvertiserComplianceStatus;
use App\Enums\ProfileStatus;
use App\Filament\Resources\AdvertiserResource;
use App\Models\Advertiser;
use App\Models\Upload;
use Filament\Actions\Action;
use Filament\Actions\DeleteAction;
use Filament\Actions\EditAction;
use Filament\Forms\Components\Select;
use Filament\Infolists\Components\Fieldset;
use Filament\Infolists\Components\ImageEntry;
use Filament\Infolists\Components\RepeatableEntry;
use Filament\Infolists\Components\Section;
use Filament\Infolists\Components\TextEntry;
use Filament\Infolists\Infolist;
use Filament\Resources\Pages\ViewRecord;

class ViewAdvertiser extends ViewRecord
{
    protected static string $resource = AdvertiserResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Action::make('Update Status')
                ->form([
                    Select::make('profile_status')
                        ->label('Status')
                        ->formatStateUsing(callback: fn ($record) => $record->profile_status)
                        ->options(ProfileStatus::class)
                        ->required(),
                    Select::make('compliance_status')
                        ->label('Compliance')
                        ->formatStateUsing(callback: fn ($record) => $record->compliance_status)
                        ->options(AdvertiserComplianceStatus::class)
                        ->required(),
                ])
                ->visible(fn ($record) => AdvertiserResource::canEdit($record))
                ->action(fn (array $data, Advertiser $record) => $record
                    ->update([
                        'profile_status' => $data['profile_status'],
                        'compliance_status' => $data['compliance_status'],

                    ]

                    )),
            EditAction::make(),
            DeleteAction::make(),
        ];
    }

    public static function getResourceInfolist(Infolist $infolist)
    {
        return $infolist->schema([
            Section::make(___('advertiser').' Information')->columnSpanFull()->schema([

                Fieldset::make('Contact')->columns(4)->schema([
                    TextEntry::make('user.title')->label('Title'),
                    TextEntry::make('user.first_name')->label('First name'),
                    TextEntry::make('user.last_name')->label('Last name'),
                    TextEntry::make('user.email')->label('Email'),
                    TextEntry::make('user.telephone')->label('Telephone'),
                    TextEntry::make('user.date_of_birth')->label('Date of birth')->date(),

                ]),

                Fieldset::make('Address')
                    ->columns(4)
                    ->visible(function (Advertiser $record) {
                        return (bool) $record->address;
                    })
                    ->schema([
                        TextEntry::make('address.line_1')->label('Line 1'),
                        TextEntry::make('address.line_2')->label('Line 2'),
                        TextEntry::make('address.town_city')->label('Town/City'),
                        TextEntry::make('address.postcode')->label('Postcode'),
                        TextEntry::make('address.country.name')->label('Country'),
                    ]),

                Fieldset::make(___('advertiser'))->columns(4)->schema([
                    TextEntry::make('profile_status')->label('Status')->badge(),
                    TextEntry::make('compliance_status')->label('Compliance')->badge(),
                    TextEntry::make('name'),
                    TextEntry::make('email'),
                    TextEntry::make('telephone'),
                    TextEntry::make('bio')->columnSpanFull(),
                    TextEntry::make('additional_info')->columnSpanFull(),
                    ImageEntry::make('photograph')
                        ->checkFileExistence(false)
                        ->width('100%')
                        ->height('unset')
                        ->getStateUsing(function ($record) {
                            if (! $record->photograph_id) {
                                return null;
                            }
                            $url = Upload::query()->find($record->photograph_id)->url;

                            return $url;
                        }),                ]),

                Fieldset::make('Contracts')->columns(1)->schema([
                    RepeatableEntry::make('contracts')
                        ->columns(2)
                        ->hiddenLabel()
                        ->schema([
                            TextEntry::make('title'),
                            TextEntry::make('upload_id')
                                ->label('Upload')
                                ->state('Link')
                                ->url(function ($record) {
                                    if (! $record->upload_id) {
                                        return null;
                                    }

                                    return Upload::query()->find($record->upload_id)->url;
                                })
                                ->openUrlInNewTab(),
                        ]),
                ]),
            ]),

        ]);

    }
}

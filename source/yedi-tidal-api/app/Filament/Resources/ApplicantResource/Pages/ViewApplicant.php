<?php

namespace App\Filament\Resources\ApplicantResource\Pages;

use App\Enums\ApplicantComplianceStatus;
use App\Enums\ProfileStatus;
use App\Enums\ReferenceStatus;
use App\Filament\Infolists\Components\VideoEntry;
use App\Filament\Resources\ApplicantResource;
use App\Models\Applicant;
use App\Models\Upload;
use App\Models\VideoVerification;
use Filament\Actions\Action;
use Filament\Actions\DeleteAction;
use Filament\Actions\EditAction;
use Filament\Forms\Components\Repeater;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Infolists\Components\Fieldset;
use Filament\Infolists\Components\Group;
use Filament\Infolists\Components\IconEntry;
use Filament\Infolists\Components\ImageEntry;
use Filament\Infolists\Components\RepeatableEntry;
use Filament\Infolists\Components\Tabs;
use Filament\Infolists\Components\Tabs\Tab;
use Filament\Infolists\Components\TextEntry;
use Filament\Resources\Pages\ViewRecord;
use Filament\Support\Enums\IconPosition;
use Filament\Support\Enums\MaxWidth;

class ViewApplicant extends ViewRecord
{
    protected static string $resource = ApplicantResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Action::make('Update Status')
                ->fillForm(function ($record) {
                    return [
                        'profile_status' => $record['profile_status'],
                        'compliance_status' => $record['compliance_status'],
                    ];
                })
                ->form([
                    Select::make('profile_status')
                        ->label('Status')
                        // ->formatStateUsing(callback: fn ($record) => $record->profile_status)
                        ->options(ProfileStatus::class)
                        ->required(),
                    Select::make('compliance_status')
                        ->label('Compliance')
                        // ->formatStateUsing(callback: fn ($record) => $record->compliance_status)
                        ->options(ApplicantComplianceStatus::class)
                        ->required(),
                ])
                ->visible(fn ($record) => ApplicantResource::canEdit($record))
                ->action(fn (array $data, Applicant $record) => $record
                    ->update([
                        'profile_status' => $data['profile_status'],
                        'compliance_status' => $data['compliance_status'],
                    ])),
            Action::make('Update References')
                ->slideOver()
                ->modalWidth(MaxWidth::ScreenLarge)
                ->fillForm(function ($record) {
                    return ['references' => $record->references];
                })
                ->form([
                    Repeater::make('references')
                        ->columns(4)
                        ->relationship('references')
                        ->schema([
                            TextInput::make('name')->required(),
                            TextInput::make('telephone')->required(),
                            TextInput::make('email')
                                ->email()
                                ->required(),
                            Select::make('status')
                                ->options(ReferenceStatus::class)
                                ->required(),
                        ]),
                ])
                ->visible(fn ($record) => ApplicantResource::canEdit($record))
                ->action(fn (array $data, Applicant $record) => $record
                    ->update(['references' => $data])
                ),
            EditAction::make(),
            DeleteAction::make(),

        ];
    }

    public static function getInfoSchema(): array
    {
        return [
            Tabs::make('Tabs')->columnSpanFull()->tabs([

                Tab::make('Personal')->schema([
                    Fieldset::make('Personal')
                        ->columns(4)
                        ->schema([
                            TextEntry::make('user.title')->label('Title'),
                            TextEntry::make('user.first_name')->label('First name'),
                            TextEntry::make('user.last_name')->label('Last name'),
                            TextEntry::make('user.email')->label('Email'),
                            TextEntry::make('user.telephone')->label('Telephone'),
                            TextEntry::make('user.date_of_birth')->label('Date of birth')->date(),
                        ]),
                    Fieldset::make('Address')
                        ->columns(4)
                        ->visible(function (Applicant $record) {
                            return (bool) $record->address;
                        })
                        ->schema([
                            TextEntry::make('address.line_1')->label('Line 1'),
                            TextEntry::make('address.line_2')->label('Line 2'),
                            TextEntry::make('address.town_city')->label('Town/City'),
                            TextEntry::make('address.postcode')->label('Postcode'),
                            TextEntry::make('address.country.name')->label('Country'),
                        ]),

                    Fieldset::make('Details')
                        ->columns(4)
                        ->schema([
                            TextEntry::make('profile_status')->label('Status')->badge(),
                            TextEntry::make('compliance_status')->label('Compliance')->badge(),
                            TextEntry::make('jobRole.name')->label('Job Role'),
                            TextEntry::make('typeOfWork.name')->label('Type of work'),
                            TextEntry::make('qualification'),
                            TextEntry::make('rating')->icon('heroicon-m-star')->iconPosition(IconPosition::After),
                            TextEntry::make('teacher_number')->badge()
                                ->visible(fn () => config('app.configuration') === 'yedi'),
                        ]),
                ]),
                Tab::make('Identification')->columns(4)->schema([

                    ImageEntry::make('photograph')
                        ->checkFileExistence(false)
                        ->width('100%')
                        ->height('unset')
                        ->getStateUsing(function ($record) {
                            if (! $record->photograph_id) {
                                return null;
                            }

                            return Upload::query()->find($record->photograph_id)->url;
                        }),
                    ImageEntry::make('evidence_of_id_id')
                        ->label('Evidence of ID')
                        ->width('100%')
                        ->height('unset')
                        ->getStateUsing(function ($record) {
                            if (! $record->evidence_of_id_id) {
                                return null;
                            }

                            return Upload::query()->find($record->evidence_of_id_id)->url;
                        }),

                    VideoEntry::make('video_verification')
                        ->getStateUsing(function ($record) {
                            if (! $record->video_verification_id) {
                                return null;
                            }
                            $video = VideoVerification::query()->find($record->video_verification_id);
                            $url = Upload::query()->find($video->upload_id)->url;

                            return ['url' => $url, 'text' => $video->code];
                        }),
                ]),
                Tab::make('Work')->schema([
                    Fieldset::make('References')
                        ->schema([
                            RepeatableEntry::make('references')
                                ->columns(4)
                                ->columnSpanFull()
                                ->hiddenLabel()
                                ->schema([

                                    TextEntry::make('name')->inlineLabel(),

                                    TextEntry::make('telephone')->inlineLabel(),
                                    TextEntry::make('email')->inlineLabel(),
                                    Group::make([
                                        TextEntry::make('status')->inlineLabel()->badge(),

                                        TextEntry::make('upload_id')
                                            ->visible(fn ($record) => (bool) $record->upload_id)
                                            ->hiddenLabel()

                                            ->state('Download')
                                            ->icon('heroicon-o-arrow-down-tray')
                                            ->url(function ($record) {
                                                if (! $record->upload_id) {
                                                    return null;
                                                }

                                                return Upload::query()->find($record->upload_id)->url;
                                            })->openUrlInNewTab(),
                                    ])->columns(2),

                                ]),
                        ]),
                    Fieldset::make('Right To Work Declaration')
                        ->columns(4)
                        ->relationship('rightToWorkDeclaration')
                        ->schema([
                            IconEntry::make('right_to_work_uk')
                                ->boolean(),
                            IconEntry::make('require_visa_to_work_uk')
                                ->boolean(),
                            IconEntry::make('lived_or_worked_outside_uk_6_months')
                                ->boolean(),
                            IconEntry::make('has_criminal_convictions_or_prosecutions_pending')
                                ->boolean(),
                        ]),

                    Fieldset::make('Declaration Agreements')
                        ->schema([
                            RepeatableEntry::make('declarationAgreements')
                                ->hiddenLabel()
                                ->columnSpanFull()
                                ->columns(4)
                                ->schema([
                                    TextEntry::make('declaration.title')->label('Title'),
                                    TextEntry::make('declaration.updated_at')->label('Updated')->dateTime(),
                                ]),

                        ]),

                    Fieldset::make('Required Evidence')
                        ->schema([
                            RepeatableEntry::make('applicantEvidence')
                                ->hiddenLabel()
                                ->columns(4)
                                ->columnSpanFull()

                                ->schema([
                                    TextEntry::make('requiredEvidence.title'),
                                    IconEntry::make('requiredEvidence.required')->boolean(),
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
                Tab::make('Contracts')->schema([
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
        ];
    }
}

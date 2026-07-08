<?php

namespace App\Filament\Resources\ApplicantResource\Pages;

use App\Enums\AdvertiserComplianceStatus;
use App\Enums\ApplicantComplianceStatus;
use App\Enums\ApplicantQualification;
use App\Enums\ProfileStatus;
use App\Enums\ReferenceStatus;
use App\Enums\UserTitle;
use App\Filament\Resources\AddressResource;
use App\Filament\Resources\ApplicantResource;
use App\Handlers\Uploads\UploadFileHandler;
use App\Models\Address;
use App\Models\Applicant;
use App\Models\ApplicantEvidence;
use App\Models\Declaration;
use App\Models\DeclarationAgreement;
use App\Models\JobRole;
use App\Models\RequiredEvidence;
use App\Models\TypeOfWork;
use App\Models\Upload;
use App\Models\VideoVerification;
use Faker\Generator as Faker;
use Filament\Forms\Components\Actions;
use Filament\Forms\Components\Actions\Action;
use Filament\Forms\Components\CheckboxList;
use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Repeater;
use Filament\Forms\Components\Section;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Resources\Pages\EditRecord;
use Illuminate\Support\Facades\DB;

// use Illuminate\Database\Eloquent\Model;
// use Illuminate\Support\Facades\DB;

class EditApplicant extends EditRecord
{
    protected static string $resource = ApplicantResource::class;

    // After saving an edit redirect back to the view page
    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('view', ['record' => $this->record]);
    }

    public static function getEditSchema(): array
    {
        return [
            Section::make('User Details')
                ->columns(4)
                ->relationship('user')
                ->schema([
                    Select::make('title')
                        ->required()
                        ->options(UserTitle::class),
                    TextInput::make('first_name')
                        ->required(),
                    TextInput::make('last_name')
                        ->required(),
                    TextInput::make('email')
                        ->email()
                        ->required()
                        ->unique(ignoreRecord: true),
                    TextInput::make('telephone')
                        ->required()
                        ->tel(),
                    DatePicker::make('date_of_birth')
                        ->required(),
                ]),
            Section::make('Address')
                ->columns(2)
                ->schema([
                    Select::make('address_id')
                        ->hiddenLabel()
                        ->createOptionForm(AddressResource::getFormSchema())
                        ->preload()

                        ->createOptionUsing(function ($data, $record) {
                            $address = Address::create($data);
                            $address->owner()->associate($record)->save();

                            return $address->id;
                        })
                        ->options(function ($record) {
                            return Address::where('owner_id', $record->id)
                                ->get()
                                ->pluck('formatted', 'id');
                        }),
                ]),

            Section::make(heading: 'Details')
                ->columns(4)
                ->schema([
                    Select::make('profile_status')
                        ->label('Status')
                        ->options(ProfileStatus::class)
                        ->required(),
                    Select::make('compliance_status')
                        ->label('Compliance')
                        ->options(ApplicantComplianceStatus::class)
                        ->required(),
                    Select::make('qualification')
                        ->options(ApplicantQualification::class),
                    Select::make('job_role_id')
                        ->label('Job Role')
                        ->options(JobRole::all()->pluck('name', 'id')),
                    Select::make('type_of_work_id')
                        ->label('Type of Work')
                        ->options(TypeOfWork::all()->pluck('name', 'id')),
                    TextInput::make('teacher_number')
                        ->visible(condition: fn () => config('app.configuration') === 'yedi')
                        ->maxLength(255),
                ]),

            Section::make('Identification')
                ->columns(4)
                ->schema([
                    FileUpload::make('photograph_id')
                        ->label('Photograph')
                        ->image()
                        ->previewable()
                        ->fetchFileInformation(false)
                        ->getUploadedFileUsing(function (string $file) {
                            $url = Upload::query()->find($file)->url;

                            return ['url' => $url];
                        })
                        ->saveUploadedFileUsing(function ($file, UploadFileHandler $uploadFileHandler, Applicant $record) {
                            $upload = $uploadFileHandler->handle($file);
                            $upload->owner()->associate($record)->save();

                            return strval($upload->id);
                        }),
                    FileUpload::make('evidence_of_id_id')
                        ->label('Evidence of ID')
                        ->image()
                        ->previewable()
                        ->fetchFileInformation(false)
                        ->getUploadedFileUsing(function (string $file) {
                            $url = Upload::query()->find($file)->url;

                            return ['url' => $url];
                        })
                        ->saveUploadedFileUsing(function ($file, UploadFileHandler $uploadFileHandler, $record) {
                            $upload = $uploadFileHandler->handle($file);
                            $upload->owner()->associate($record)->save();

                            return strval($upload->id);
                        }),
                    FileUpload::make('video_verification_id')
                        ->label('Video Verification')
                        ->acceptedFileTypes(['video/*'])
                        // FORM: can delete but can't upload
                        ->hidden(fn ($state) => empty($state))
                        ->dehydratedWhenHidden(true)
                        ->fetchFileInformation(false)
                        ->getUploadedFileUsing(function (string $file) {
                            $video = VideoVerification::query()->find($file);
                            $upload = Upload::query()->find($video)->first();

                            return ['url' => $upload->url];
                        })
                        ->saveUploadedFileUsing(function ($file, UploadFileHandler $uploadFileHandler, $record) {
                            $upload = $uploadFileHandler->handle($file);
                            $upload->owner()->associate($record)->save();
                            $videoVerification = $record->videoVerifications()->create();
                            $videoVerification->upload()->associate($upload)->save();
                            $upload->owner()->associate($videoVerification)->save();

                            return strval($videoVerification->id);
                        }),

                ]),

            Section::make(heading: 'References')
                ->schema([
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
                ]),

            Section::make(heading: 'Right To Work Declaration')
                ->columns(4)
                ->relationship('rightToWorkDeclaration')
                ->schema([
                    Toggle::make('right_to_work_uk'),
                    Toggle::make('require_visa_to_work_uk'),
                    Toggle::make('lived_or_worked_outside_uk_6_months'),
                    Toggle::make('has_criminal_convictions_or_prosecutions_pending'),
                ]),

            Section::make(heading: 'Declaration Agreements')->schema([
                CheckboxList::make('declarationAgreements')
                    ->columns(3)
                    ->options(Declaration::all()->pluck('title', 'id'))
                    ->formatStateUsing(function ($record) {
                        return array_values($record->declarationAgreements->pluck('declaration_id')->toArray());
                    })
                    ->saveRelationshipsUsing(function ($state, $record) {
                        $declarations = Declaration::all()->pluck('title', 'id')->toArray();
                        foreach (array_keys($declarations) as $declaration) {
                            $existing = $record->declarationAgreements()->where('declaration_id', $declaration)->first();
                            $isSelected = in_array($declaration, $state);

                            if ($existing && $isSelected) {
                                $existing->touch();
                            } elseif ($existing && ! $isSelected) {
                                $existing->delete();
                            } elseif (! $existing && $isSelected) {
                                $new = new DeclarationAgreement;
                                $new->declaration()->associate($declaration);
                                $new->applicant()->associate($record);
                                $new->save();
                            }
                        }
                    }),
            ]),

            Section::make(heading: 'Required Evidence')
                ->schema([
                    Repeater::make('applicantEvidence')
                        ->columns(3)
                        ->relationship('applicantEvidence')
                        ->schema([
                            Select::make('required_evidence_id')
                                ->label('Required Evidence')
                                ->options(RequiredEvidence::all()->pluck('title', 'id'))
                                ->required(),
                            FileUpload::make('upload_id')
                                ->label('Upload')
                                ->fetchFileInformation(false)
                                ->getUploadedFileUsing(function (string $file) {
                                    $upload = Upload::query()->find($file)->first();

                                    return ['url' => $upload->url];
                                })
                                ->saveUploadedFileUsing(function ($file, UploadFileHandler $uploadFileHandler, $record) {
                                    $upload = $uploadFileHandler->handle($file);
                                    $upload->owner()->associate($record)->save();

                                    return strval($upload->id);
                                }),
                        ])->saveRelationshipsUsing(function ($state, $record) {
                            foreach (array_values($state) as $data) {
                                try {
                                    DB::beginTransaction();

                                    $requiredEvidence = RequiredEvidence::query()->findOrFail($data['required_evidence_id']);
                                    $record->applicantEvidence()->where('required_evidence_id', $requiredEvidence->id)->delete();
                                    $upload = Upload::query()->findOrFail($data['upload_id'])[0];

                                    $evidence = new ApplicantEvidence;
                                    $evidence->applicant()->associate($record);
                                    $evidence->requiredEvidence()->associate($requiredEvidence);
                                    $evidence->upload()->associate($upload);
                                    $evidence->save();

                                    $upload->owner()->associate($record)->save();

                                    DB::commit();
                                } catch (\Throwable $th) {
                                    DB::rollBack();
                                    throw $th;
                                }
                            }
                        }),
                ]),

            Actions::make([
                Action::make('fill')
                    ->icon('heroicon-m-star')
                    ->action(function ($livewire, Faker $faker) {
                        $livewire->form->fill([
                            'name' => $faker->company(),
                            'email' => $faker->email(),
                            'telephone' => $faker->phoneNumber(),
                            'bio' => $faker->sentences(),
                            'additional_info' => $faker->sentences(),
                            'compliance_status' => $faker->randomElement(AdvertiserComplianceStatus::class),
                        ]);
                    }),
            ])->visible(fn () => app()->environment('local') ? true : false),
        ];

    }

    public function getRelationManagers(): array
    {
        return [];
    }
}

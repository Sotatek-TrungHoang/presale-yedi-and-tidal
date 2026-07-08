<?php

namespace App\Filament\Resources\AdvertiserResource\Pages;

use App\Enums\AdvertiserComplianceStatus;
use App\Enums\ProfileStatus;
use App\Enums\UserTitle;
use App\Enums\UserType;
use App\Filament\Resources\AddressResource;
use App\Filament\Resources\AdvertiserResource;
use App\Handlers\Uploads\UploadFileHandler;
use App\Models\Address;
use App\Models\Upload;
use Faker\Generator as Faker;
use Filament\Forms\Components\Actions;
use Filament\Forms\Components\Actions\Action;
use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Hidden;
use Filament\Forms\Components\Section;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Resources\Pages\CreateRecord;
use Filament\Resources\Pages\EditRecord;

class EditAdvertiser extends EditRecord
{
    protected static string $resource = AdvertiserResource::class;

    protected function getRedirectUrl(): string
    {
        return $this->getResource()::getUrl('view', ['record' => $this->record]);
    }

    public static function getEditFormSchema()
    {
        return [

            Section::make('Contact Details')
                ->columns(2)
                ->relationship('user')
                ->columns(4)
                ->columnSpan(2)
                ->schema([
                    Hidden::make('type')->formatStateUsing(fn () => UserType::Advertiser),
                    Select::make('title')
                        ->required()
                        ->options(UserTitle::class),
                    TextInput::make('first_name')
                        ->required(),
                    TextInput::make('last_name')
                        ->required(),
                    TextInput::make('email')
                        ->email()
                        ->unique(ignoreRecord: true)
                        ->required(),
                    TextInput::make('telephone')
                        ->required()
                        ->tel(),
                    DatePicker::make('date_of_birth')
                        ->required(),
                    TextInput::make('password')
                        ->required()
                        ->password()
                        ->visible(fn ($livewire) => $livewire  instanceof CreateRecord),

                ]),

            Section::make(___('advertiser').' Details')
                ->columns(4)
                ->schema([
                    Select::make('profile_status')
                        ->label('Status')
                        ->required()
                        ->options(ProfileStatus::class)
                        // hidden on create. Default to incomplete and dehydrate
                        ->dehydratedWhenHidden()
                        ->default(ProfileStatus::Incomplete)
                        ->visible(fn ($operation) => $operation === 'edit'),
                    Select::make('compliance_status')
                        ->label('Compliance')
                        ->required()
                        ->options(AdvertiserComplianceStatus::class)
                        // hidden on create. Default to pending and dehydrate
                        ->dehydratedWhenHidden()
                        ->default(AdvertiserComplianceStatus::Pending)
                        ->visible(fn ($operation) => $operation === 'edit'),
                    TextInput::make('name')
                        ->required()
                        ->maxLength(255),
                    TextInput::make('email')
                        ->email()
                        ->unique(ignoreRecord: true)
                        ->required()
                        ->maxLength(255),
                    TextInput::make('telephone')
                        ->tel()
                        ->required()
                        ->maxLength(255),
                    Select::make('address_id')
                        ->relationship('address')
                        ->label('Address')
                        ->createOptionForm(AddressResource::getFormSchema())
                        ->columnSpan(2)
                        ->preload()
                        ->createOptionUsing(function ($data, $record) {
                            $address = Address::create($data);
                            $address->owner()->associate($record)->save();

                            return $address->id;
                        })
                        ->options(function ($record) {
                            return Address::where('owner_id', $record?->id)
                                ->get()
                                ->pluck('formatted', 'id');
                        }),
                    Textarea::make('bio')
                        ->columnSpanFull(),
                    Textarea::make('additional_info')
                        ->columnSpanFull(),
                    FileUpload::make('photograph_id')
                        ->label('Photograph')
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
                ]),

            Actions::make([
                Action::make('fill')
                    ->icon('heroicon-m-star')
                    ->action(function ($livewire, Faker $faker) {
                        $livewire->form->fill([
                            'user' => [
                                'title' => $faker->randomElement(UserTitle::class),
                                'first_name' => $faker->firstName,
                                'last_name' => $faker->lastName,
                                'email' => $faker->email(),
                                'telephone' => $faker->phoneNumber(),
                                'password' => 'password',
                                'date_of_birth' => $faker->dateTimeBetween('-60 years', '-20 years')->format('Y-m-d H:i:s'),
                            ],
                            'profile_status' => ProfileStatus::Pending,
                            'compliance_status' => AdvertiserComplianceStatus::Pending,
                            'name' => $faker->company(),
                            'email' => $faker->email(),
                            'telephone' => $faker->phoneNumber(),
                            'bio' => $faker->sentences(asText: true),
                            'additional_info' => $faker->sentences(asText: true),
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

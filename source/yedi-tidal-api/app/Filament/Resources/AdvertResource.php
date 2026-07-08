<?php

namespace App\Filament\Resources;

use App\Enums\AdvertStatus;
use App\Enums\AdvertType;
use App\Enums\PayType;
use App\Filament\Resources\AdvertResource\Pages;
use App\Filament\Resources\AdvertResource\Pages\ViewAdvert;
use App\Filament\Resources\AdvertResource\RelationManagers\ApplicantsRelationManager;
use App\Models\Address;
use App\Models\Advert;
use App\Models\Advertiser;
use App\Models\Upload;
use App\Rules\TimeRule;
use Brick\Money\Money;
use Faker\Generator as Faker;
use Filament\Forms\Components\Actions;
use Filament\Forms\Components\DatePicker;
use Filament\Forms\Components\Fieldset;
use Filament\Forms\Components\FileUpload;
use Filament\Forms\Components\Group;
use Filament\Forms\Components\Repeater;
use Filament\Forms\Components\Section;
use Filament\Forms\Components\Select;
use Filament\Forms\Components\Textarea;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Form;
use Filament\Infolists\Infolist;
use Filament\Resources\Resource;
use Filament\Tables;
use Filament\Tables\Columns\TextColumn;
use Filament\Tables\Table;
use Illuminate\Contracts\Support\Htmlable;
use Illuminate\Database\Eloquent\Model;

class AdvertResource extends Resource
{
    protected static ?string $model = Advert::class;

    protected static ?string $navigationIcon = 'heroicon-o-newspaper';

    protected static ?int $navigationSort = 20;

    public static function getLabel(): string
    {
        return ___('advert');
    }

    public static function getFormSchema()
    {
        return [
            Section::make(heading: ___('advert').' Details')->columns(4)->schema([
                TextInput::make('title')
                    ->required()
                    ->maxLength(255),
                Select::make('advertiser_id')
                    ->label(___(key: 'advertiser'))
                    ->options(Advertiser::all()->pluck('name', 'id'))
                    // data
                    ->default(request()->query('advertiser_id'))
                    ->required(),
                Select::make('type')
                    ->options(AdvertType::class)
                    ->required(),
                Select::make('status')
                    ->options(AdvertStatus::class)
                    ->required(),
                Select::make('address_id')
                    ->label('Address')
                    ->required()
                    ->columnSpan(2)
                    ->createOptionForm(AddressResource::getFormSchema())
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
                Fieldset::make('Date')->columnStart(1)->columnSpan(2)->schema([
                    DatePicker::make('starts_at')
                        ->required(),
                    DatePicker::make('ends_at')
                        ->required(),
                ]),
                Fieldset::make('Shift')->columnSpan(2)->schema([
                    TextInput::make('shift_start_time')
                        ->rules([new TimeRule])
                        ->label('Start time')
                        ->required()
                        ->hint('24-hour: 09:00'),
                    TextInput::make('shift_end_time')
                        ->rules([new TimeRule])
                        ->label('End time')
                        ->required()
                        ->hint('24-hour: 17:00'),
                ]),
                DatePicker::make('apply_by')
                    ->required(),
                Textarea::make('description')
                    ->required()
                    ->rows(4)
                    ->columnSpanFull(),
            ]),

            Section::make(heading: 'Documents')->columns(4)->schema([
                Repeater::make('documents')
                    ->addable(false)
                    ->hiddenLabel()
                    ->columnSpanFull()
                    ->relationship('documents')
                    ->schema([
                        Group::make()
                            ->columns(2)
                            ->schema([
                                TextInput::make('title'),
                                FileUpload::make('upload_id')
                                    ->label('Upload')
                                    ->disabled()
                                    ->openable()
                                    ->fetchFileInformation(false)
                                    ->getUploadedFileUsing(function ($file) {
                                        $url = Upload::query()->find($file)->url;

                                        return ['url' => $url];
                                    }),
                            ]),
                    ]),
            ]),

            Section::make(heading: 'Payment & Charges')->columns(4)->schema([
                TextInput::make('advertiser_pay_rate')
                    ->label(___('advertiser').' Pay Rate')
                    ->numeric()
                    ->formatStateUsing(function ($state) {
                        return match (gettype($state)) {
                            'object' => $state->getAmount()->toFloat(),
                            default => $state
                        };
                    })
                    ->dehydrateStateUsing(fn ($state) => Money::of($state, 'GBP'))
                    ->required(),
                Select::make('advertiser_pay_rate_type')
                    ->label(___('advertiser').' Pay Rate Type')
                    ->required()
                    ->options(PayType::class),
                TextInput::make('advertiser_charge_percentage')
                    ->label(___('advertiser').' Charge %')
                    ->required()
                    ->numeric(),
                TextInput::make('applicant_charge_percentage')
                    ->label(___('applicant').' Charge %')
                    ->required()
                    ->numeric(),
            ]),

            Actions::make([
                Actions\Action::make('fill')
                    ->icon('heroicon-m-star')
                    ->action(function ($livewire, Faker $faker) {
                        $livewire->form->fill([
                            'title' => $faker->jobTitle(),
                            'advertiser_id' => $faker->randomElement(array: Advertiser::all())->id,
                            'type' => $faker->randomElement(array: AdvertType::class),
                            'status' => $faker->randomElement(AdvertStatus::class),
                            'starts_at' => $faker->dateTimeBetween('1 week', '2 weeks')->format('Y-m-d H:i:s'),
                            'ends_at' => $faker->dateTimeBetween('1 month', '2 months')->format('Y-m-d H:i:s'),
                            'shift_start_time' => $faker->randomElement(['09:00', '08:30', '08:00']),
                            'shift_end_time' => $faker->randomElement(['16:30', '17:30', '17:00']),
                            'apply_by' => $faker->dateTimeBetween('now', '1 week')->format('Y-m-d H:i:s'),
                            'description' => $faker->sentences(asText: true),
                            //
                            'documents' => [],
                            'advertiser_pay_rate' => $faker->randomElement([40, 35.99, 29.50]),
                            'advertiser_pay_rate_type' => $faker->randomElement(array: PayType::class),
                            'applicant_charge_percentage' => $faker->numberBetween(1, 10),
                            'advertiser_charge_percentage' => $faker->numberBetween(1, 10),
                        ]);
                    }),
            ]),
        ];

    }

    public static function form(Form $form): Form
    {
        return $form->schema(self::getFormSchema());
    }

    public static function table(Table $table): Table
    {

        return $table
            ->columns([

                TextColumn::make('advertiser.name')
                    ->label(___('advertiser'))
                    ->numeric()
                    ->sortable(),
                TextColumn::make('type')
                    ->badge()
                    ->searchable(),
                TextColumn::make('status')
                    ->badge()
                    ->searchable(),
                TextColumn::make('title')
                    ->searchable(),
                TextColumn::make('applications_count')
                    ->label('Applications')
                    ->counts('applications')
                    ->sortable(),
                TextColumn::make('starts_at')
                    ->date()
                    ->sortable(),
                TextColumn::make('ends_at')
                    ->date()
                    ->sortable(),
                TextColumn::make('apply_by')
                    ->date()
                    ->sortable(),
                TextColumn::make('created_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
                TextColumn::make('updated_at')
                    ->dateTime()
                    ->sortable()
                    ->toggleable(isToggledHiddenByDefault: true),
                TextColumn::make('deleted_at')
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
        return $infolist->schema(ViewAdvert::getInfoSchema());

    }

    public static function getRelations(): array
    {
        return [
            ApplicantsRelationManager::class,
        ];
    }

    public static function getPages(): array
    {
        return [
            'index' => Pages\ListAdverts::route('/'),
            'create' => Pages\CreateAdvert::route('/create'),
            'edit' => Pages\EditAdvert::route('/{record}/edit'),
            'view' => Pages\ViewAdvert::route('/{record}'),
        ];
    }

    // GLOBAL search setup
    protected static ?string $recordTitleAttribute = 'user.name';

    public static function getGlobalSearchResultTitle(Model $record): string|Htmlable
    {
        return $record->title;
    }

    public static function getGloballySearchableAttributes(): array
    {
        return ['title', 'description', 'advertiser.name', 'address.line_1', 'address.town_city', 'address.postcode'];
    }

    public static function getGlobalSearchResultUrl(Model $record): string
    {
        return AdvertResource::getUrl('view', ['record' => $record]);
    }

    public static function getGlobalSearchResultDetails(Model $record): array
    {
        return [
            ___('advertiser') => $record->advertiser->name,
        ];
    }
}

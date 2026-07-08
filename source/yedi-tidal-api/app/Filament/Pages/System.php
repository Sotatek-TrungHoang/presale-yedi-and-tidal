<?php

namespace App\Filament\Pages;

use App\Forms\Components\RichEditorTemplateStrings;
use App\Models\Settings;
use Filament\Actions\Action;
use Filament\Forms\Components\RichEditor;
use Filament\Forms\Components\Section;
use Filament\Forms\Components\TextInput;
use Filament\Forms\Components\Toggle;
use Filament\Forms\Concerns\InteractsWithForms;
use Filament\Forms\Contracts\HasForms;
use Filament\Forms\Form;
use Filament\Pages\Page;
use Filament\Support\Exceptions\Halt;

class System extends Page implements HasForms
{
    use InteractsWithForms;

    protected static ?string $navigationGroup = 'Settings';

    protected static ?int $navigationSort = 100;

    protected static ?string $navigationIcon = 'heroicon-o-cog';

    protected static string $view = 'filament.pages.settings';

    public ?array $form_data = [];

    public function mount(): void
    {
        $record = Settings::first();
        $this->form->fill([
            'require_teacher_number' => $record->require_teacher_number,
            'references_required' => $record->references_required,
            'default_applicant_charge_percentage' => $record->default_applicant_charge_percentage,
            'default_advertiser_charge_percentage' => $record->default_advertiser_charge_percentage,
            //
            'invoice_due_date_days' => $record->invoice_due_date_days,
            'invoice_late_payment_charge_percent' => $record->invoice_late_payment_charge_percent,
            'invoice_payment_account_name' => $record->invoice_payment_account_name,
            'invoice_payment_account_number' => $record->invoice_payment_account_number,
            'invoice_payment_account_sort_code' => $record->invoice_payment_account_sort_code,
            'invoice_contact_email' => $record->invoice_contact_email,
            'invoice_contact_telephone' => $record->invoice_contact_telephone,
            'invoice_contact_address' => $record->invoice_contact_address,
            //
            'applicant_contract' => $record->applicant_contract,
            'advertiser_contract' => $record->advertiser_contract,
        ]);
    }

    public function form(Form $form): Form
    {
        return $form
            ->columns(2)
            ->schema([
                Toggle::make('require_teacher_number')
                    ->columnSpanFull()
                    ->visible(fn () => config('app.configuration') === 'yedi'),
                TextInput::make('references_required')
                    ->numeric()
                    ->required(),
                TextInput::make('default_applicant_charge_percentage')
                    ->columnStart(1)
                    ->numeric()->minValue(0)->maxValue(100)->extraInputAttributes(['step' => '0.01'])
                    ->required(),
                TextInput::make('default_advertiser_charge_percentage')
                    ->numeric()->minValue(0)->maxValue(100)->extraInputAttributes(['step' => '0.01'])
                    ->required(),
                Section::make('Invoices')->columns(2)->schema([
                    TextInput::make('invoice_due_date_days')
                        ->numeric()
                        ->required(),
                    TextInput::make('invoice_late_payment_charge_percent')
                        ->numeric()->minValue(0)->maxValue(100)->extraInputAttributes(['step' => '0.01'])
                        ->required(),
                    TextInput::make('invoice_payment_account_name')
                        ->required(),
                    TextInput::make('invoice_payment_account_number')
                        ->columnStart(1)
                        ->required(),
                    TextInput::make('invoice_payment_account_sort_code')
                        ->required(),
                    TextInput::make('invoice_contact_email')
                        ->columnStart(1)
                        ->email()
                        ->required(),
                    TextInput::make('invoice_contact_telephone')
                        ->tel()
                        ->required(),
                    RichEditor::make('invoice_contact_address')
                        ->columnStart(1)->columnSpanFull()
                        ->toolbarButtons(['bold', 'undo', 'redo'])
                        ->required(),
                ]),
                RichEditorTemplateStrings::make('applicant_contract')
                    ->id('applicant_contract')
                    ->columnStart(1)->columnSpanFull()
                    ->string()
                    ->templateItems([
                        ['key' => 'applicant', 'value' => '{{APPLICANT_NAME}}'],
                        ['key' => 'advertiser', 'value' => '{{ADVERTISER_NAME}}'],
                    ])
                    ->toolbarButtons(['h1', 'h2', 'h3', 'link', 'bold', 'italic', 'undo', 'redo'])
                    ->required(),
                RichEditorTemplateStrings::make('advertiser_contract')
                    ->id('advertiser_contract')
                    ->columnStart(1)->columnSpanFull()
                    ->templateItems([
                        ['key' => 'applicant', 'value' => '{{APPLICANT_NAME}}'],
                        ['key' => 'advertiser', 'value' => '{{ADVERTISER_NAME}}'],
                    ])
                    ->toolbarButtons(['h1', 'h2', 'h3', 'link', 'bold', 'italic', 'undo', 'redo'])
                    ->required(),
            ])
            ->statePath('form_data');
    }

    protected function getFormActions(): array
    {
        return [
            Action::make('save')
                ->label(__('filament-panels::resources/pages/edit-record.form.actions.save.label'))
                ->submit('save'),
        ];
    }

    public function save(): void
    {
        try {
            $data = $this->form->getState();

            Settings::first()->update($data);
        } catch (Halt $exception) {
            return;
        }
    }
}

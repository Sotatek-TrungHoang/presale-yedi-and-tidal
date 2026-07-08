<?php

namespace App\Filament\Resources\ApplicantResource\Pages;

use App\Enums\ApplicantComplianceStatus;
use App\Enums\ApplicationStatus;
use App\Filament\Resources\ApplicantResource;
use Filament\Actions;
use Filament\Resources\Components\Tab;
use Filament\Resources\Pages\ListRecords;
use Filament\Tables\Columns\TextColumn;
use Illuminate\Database\Eloquent\Builder;

class ListApplicants extends ListRecords
{
    protected static string $resource = ApplicantResource::class;

    protected function getHeaderActions(): array
    {
        return [
            Actions\CreateAction::make(),
        ];
    }

    public function getTabs(): array
    {
        return [
            'all' => Tab::make(),
            'compliant' => Tab::make()
                ->modifyQueryUsing(fn (Builder $query) => $query->where('compliance_status', ApplicantComplianceStatus::Compliant)),
            'Non-Compliant' => Tab::make()
                ->modifyQueryUsing(fn (Builder $query) => $query->where('compliance_status', ApplicantComplianceStatus::NonCompliant)),
            'Incomplete' => Tab::make()
                ->modifyQueryUsing(fn (Builder $query) => $query->where('compliance_status', ApplicantComplianceStatus::Incomplete)),
            'Pending Approval' => Tab::make()
                ->modifyQueryUsing(fn (Builder $query) => $query->where('compliance_status', ApplicantComplianceStatus::PendingApproval)),
        ];
    }

    public static function getTableSchema(): array
    {
        return [
            TextColumn::make('profile_status')
                ->label('Status')
                ->badge()
                ->searchable(),
            TextColumn::make('compliance_status')
                ->label('Compliance')
                ->badge()
                ->searchable(),
            TextColumn::make('user.name')
                ->label('Name'),
            TextColumn::make('jobRole.name')
                ->searchable(),
            TextColumn::make('typeOfWork.name')
                ->searchable(),
            TextColumn::make('teacher_number')
                ->visible(fn () => config('app.configuration') === 'yedi')
                ->searchable(),
            TextColumn::make('applications_count')->name('accepted')->counts([
                'applications as accepted' => fn (Builder $query) => $query->where('status', ApplicationStatus::Accepted),
            ]),
            TextColumn::make('applications_count')->name('cancelled')->label('Cancelled')->counts([
                'applications as cancelled' => fn (Builder $query) => $query->where('status', ApplicationStatus::Cancelled),
            ]),
            TextColumn::make('applications_count')->name('declined')->label('Declined')->counts([
                'applications as declined' => fn (Builder $query) => $query->where('status', ApplicationStatus::Declined),
            ]),
            TextColumn::make('applications_count')->name('pending')->label('Pending')->counts([
                'applications as pending' => fn (Builder $query) => $query->where('status', ApplicationStatus::Pending),
            ]),

            TextColumn::make('created_at')
                ->dateTime()
                ->sortable(),
            TextColumn::make('updated_at')
                ->dateTime()
                ->sortable()
                ->toggleable(isToggledHiddenByDefault: true),
            TextColumn::make('deleted_at')
                ->dateTime()
                ->sortable()
                ->toggleable(isToggledHiddenByDefault: true),
        ];
    }
}

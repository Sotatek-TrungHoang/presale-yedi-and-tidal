<?php

namespace App\Filament\Resources\AdvertResource\Pages;

use App\Enums\AdvertStatus;
use App\Enums\AdvertType;
use App\Filament\Resources\AdvertResource;
use Filament\Actions;
use Filament\Resources\Components\Tab;
use Filament\Resources\Pages\ListRecords;

class ListAdverts extends ListRecords
{
    protected static string $resource = AdvertResource::class;

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
            'day-to-day' => Tab::make()->modifyQueryUsing(fn ($query) => $query->where('type', AdvertType::DayToDay)),
            'long-term' => Tab::make()->modifyQueryUsing(fn ($query) => $query->where('type', AdvertType::LongTerm)),
            'approved' => Tab::make()->modifyQueryUsing(fn ($query) => $query->where('status', AdvertStatus::Approved)),
            'filled' => Tab::make()->modifyQueryUsing(fn ($query) => $query->where('status', AdvertStatus::Filled)),
            'not-filled' => Tab::make()->modifyQueryUsing(fn ($query) => $query->where('status', AdvertStatus::NotFilled)),
            'pending-allocation' => Tab::make()->modifyQueryUsing(fn ($query) => $query->where('status', AdvertStatus::PendingAllocation)),
            'pending-approval' => Tab::make()->modifyQueryUsing(fn ($query) => $query->where('status', AdvertStatus::PendingApproval)),
            'rejected' => Tab::make()->modifyQueryUsing(fn ($query) => $query->where('status', AdvertStatus::Rejected)),
        ];
    }
}

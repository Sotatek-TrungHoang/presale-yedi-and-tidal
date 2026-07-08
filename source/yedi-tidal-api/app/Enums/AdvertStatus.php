<?php

namespace App\Enums;

use Filament\Support\Colors\Color;
use Filament\Support\Contracts\HasColor;
use Filament\Support\Contracts\HasLabel;

enum AdvertStatus: string implements HasColor, HasLabel
{
    case PendingApproval = 'pending_approval';
    case Rejected = 'rejected';
    case Approved = 'approved';
    case PendingAllocation = 'pending_allocation';
    case Filled = 'filled';
    case NotFilled = 'not_filled';

    public function getLabel(): ?string
    {
        return match ($this) {
            self::PendingApproval => 'Pending Approval',
            self::Rejected => 'Approval Rejected',
            self::Approved => 'Approved',
            self::PendingAllocation => 'Pending Allocation',
            self::Filled => 'Filled',
            self::NotFilled => 'Not Filled',
            default => $this->name
        };
    }

    public function getColor(): string|array|null
    {
        return match ($this) {
            self::PendingApproval => Color::Orange,
            self::Rejected => Color::Red,
            self::Approved => 'success',
            self::PendingAllocation => Color::Yellow,
            self::Filled => Color::Green,
            self::NotFilled => Color::Blue,
            default => Color::Blue,
        };
    }
}

<?php

namespace App\Enums;

use Filament\Support\Colors\Color;
use Filament\Support\Contracts\HasColor;
use Filament\Support\Contracts\HasLabel;

enum ApplicantComplianceStatus: string implements HasColor, HasLabel
{
    case Incomplete = 'incomplete';
    case PendingApproval = 'pending_approval';
    case Compliant = 'compliant';
    case NonCompliant = 'non_compliant';

    public function getLabel(): ?string
    {
        return match ($this) {
            self::Incomplete => 'Incomplete',
            self::PendingApproval => 'Pending Approval',
            self::Compliant => 'Compliant',
            self::NonCompliant => 'Non Compliant',
            default => $this->name
        };
    }

    public function getColor(): string|array|null
    {
        return match ($this) {
            self::Incomplete => Color::Gray,
            self::PendingApproval => Color::Orange,
            self::Compliant => 'success',
            self::NonCompliant => Color::Red,
            default => Color::Blue

        };
    }
}

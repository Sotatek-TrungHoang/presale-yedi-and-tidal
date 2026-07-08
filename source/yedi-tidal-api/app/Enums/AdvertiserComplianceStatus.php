<?php

namespace App\Enums;

use Filament\Support\Colors\Color;
use Filament\Support\Contracts\HasColor;
use Filament\Support\Contracts\HasLabel;

enum AdvertiserComplianceStatus: string implements HasColor, HasLabel
{
    case Pending = 'pending';
    case Compliant = 'compliant';
    case NonCompliant = 'non_compliant';

    public function getLabel(): ?string
    {
        return match ($this) {
            self::Pending => 'Pending',
            self::Compliant => 'Compliant',
            self::NonCompliant => 'Non Compliant',
            default => $this->name
        };
    }

    public function getColor(): string|array|null
    {
        return match ($this) {
            self::Pending => Color::Orange,
            self::Compliant => Color::Green,
            self::NonCompliant => Color::Red,
            default => Color::Blue

        };
    }
}

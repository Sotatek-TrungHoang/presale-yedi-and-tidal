<?php

namespace App\Enums;

use Filament\Support\Colors\Color;
use Filament\Support\Contracts\HasColor;
use Filament\Support\Contracts\HasLabel;

enum PayType: string implements HasColor, HasLabel
{
    case Daily = 'daily';
    case Hourly = 'hourly';

    public function getLabel(): ?string
    {
        return match ($this) {
            self::Daily => 'Daily',
            self::Hourly => 'Hourly',
            default => $this->name
        };
    }

    public function getColor(): string|array|null
    {
        return match ($this) {
            self::Daily => Color::Orange,
            self::Hourly => 'success',
            default => Color::Blue

        };
    }
}

<?php

namespace App\Enums;

use Filament\Support\Colors\Color;
use Filament\Support\Contracts\HasColor;
use Filament\Support\Contracts\HasLabel;

enum AdvertType: string implements HasColor, HasLabel
{
    case DayToDay = 'day_to_day';
    case LongTerm = 'long_term';

    public function getLabel(): ?string
    {
        return match ($this) {
            self::DayToDay => 'Day to day',
            self::LongTerm => 'Long term',
            default => $this->name
        };
    }

    public function getColor(): string|array|null
    {
        return match ($this) {
            self::DayToDay => Color::Orange,
            self::LongTerm => 'success',
            default => Color::Blue

        };
    }
}

<?php

namespace App\Enums;

use Filament\Support\Colors\Color;
use Filament\Support\Contracts\HasColor;
use Filament\Support\Contracts\HasLabel;

enum ReferenceRating: string implements HasColor, HasLabel
{
    case Unsatisfactory = 'unsatisfactory';
    case Satisfactory = 'satisfactory';
    case Good = 'good';
    case Excellent = 'excellent';

    public function getLabel(): ?string
    {
        return match ($this) {
            default => $this->name
        };
    }

    public function getColor(): string|array|null
    {
        return match ($this) {
            self::Unsatisfactory => Color::Red,
            self::Satisfactory => Color::Orange,
            self::Good => Color::Blue,
            self::Excellent => Color::Green,
        };
    }
}

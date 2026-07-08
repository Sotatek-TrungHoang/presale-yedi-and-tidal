<?php

namespace App\Enums;

use Filament\Support\Colors\Color;
use Filament\Support\Contracts\HasColor;
use Filament\Support\Contracts\HasLabel;

enum ProfileStatus: string implements HasColor, HasLabel
{
    case Incomplete = 'incomplete';
    case Pending = 'pending';
    case Active = 'active';
    case Disabled = 'disabled';

    public function getLabel(): ?string
    {
        return $this->name;
    }

    public function getColor(): string|array|null
    {
        return match ($this) {
            self::Incomplete => Color::Gray,
            self::Pending => Color::Orange,
            self::Active => Color::Green,
            self::Disabled => Color::Red,
        };
    }
}

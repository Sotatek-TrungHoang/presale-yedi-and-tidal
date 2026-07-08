<?php

namespace App\Enums;

use Filament\Support\Contracts\HasLabel;

enum UserTitle: string implements HasLabel
{
    case Mr = 'mr';
    case Mrs = 'mrs';
    case Miss = 'miss';
    case Ms = 'ms';
    case Dr = 'dr';
    case Prof = 'prof';
    case Rev = 'rev';
    case Other = 'other';

    public function label()
    {
        return $this->name;
    }

    public function getLabel(): ?string
    {
        return ucfirst($this->name);

    }
}

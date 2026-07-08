<?php

namespace App\Enums;

use Filament\Support\Colors\Color;
use Filament\Support\Contracts\HasColor;
use Filament\Support\Contracts\HasLabel;

enum ReferenceStatus: string implements HasColor, HasLabel
{
    case Created = 'created';
    case SentToReferee = 'sent_to_referee';
    case PendingConfirmation = 'pending_confirmation';
    case Confirmed = 'confirmed';
    case Rejected = 'rejected';

    public function getLabel(): ?string
    {
        return match ($this) {
            self::Created => 'New',
            self::PendingConfirmation => 'Pending Confirmation',
            self::SentToReferee => 'Sent to Referee',
            default => $this->name
        };
    }

    public function getColor(): string|array|null
    {
        return match ($this) {
            self::Created => Color::Blue,
            self::SentToReferee => Color::Blue,
            self::PendingConfirmation => Color::Orange,
            self::Rejected => Color::Red,
            self::Confirmed => Color::Green,
        };
    }
}

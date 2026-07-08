<?php

namespace App\Enums;

use Filament\Support\Contracts\HasLabel;

enum UserType: string implements HasLabel
{
    case Admin = 'admin';
    case Advertiser = 'advertiser';
    case Applicant = 'applicant';

    public function getLabel(): ?string
    {
        return match ($this) {
            self::Admin => 'Admin',
            self::Advertiser => ___('advertiser'),
            self::Applicant => ___('applicant'),
            default => $this->name
        };
    }
}

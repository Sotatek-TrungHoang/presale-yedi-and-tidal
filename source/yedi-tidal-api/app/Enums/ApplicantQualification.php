<?php

namespace App\Enums;

use Filament\Support\Contracts\HasLabel;

enum ApplicantQualification: string implements HasLabel
{
    case None = 'none';
    case GCSE = 'gcse';
    case ALevel = 'a_level';
    case Degree = 'degree';
    case Masters = 'masters';
    case PhD = 'phd';
    case Other = 'other';

    public function label()
    {
        return match ($this) {
            self::None => 'None',
            self::GCSE => 'GCSE',
            self::ALevel => 'A Level',
            self::Degree => 'Degree',
            self::Masters => 'Masters',
            self::PhD => 'PhD',
            self::Other => 'Other',
        };
    }

    public function getLabel(): ?string
    {
        return match ($this) {
            self::None => 'None',
            self::GCSE => 'GCSE',
            self::ALevel => 'A Level',
            self::Degree => 'Degree',
            self::Masters => 'Masters',
            self::PhD => 'PhD',
            self::Other => 'Other',
            default => $this->name
        };
    }
}

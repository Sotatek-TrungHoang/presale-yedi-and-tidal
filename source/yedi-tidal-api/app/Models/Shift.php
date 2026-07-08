<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use OwenIt\Auditing\Auditable;
use OwenIt\Auditing\Contracts\Auditable as AuditableContract;

class Shift extends Model implements AuditableContract
{
    use Auditable, HasFactory, SoftDeletes;

    protected $fillable = [
        'starts_at',
        'ends_at',
    ];

    protected function casts(): array
    {
        return [
            'starts_at' => 'datetime',
            'ends_at' => 'datetime',
        ];
    }

    protected $appends = [
        'hours',
    ];

    public function advert()
    {
        return $this->belongsTo(Advert::class);
    }

    public function getMinutesAttribute(): int
    {
        return $this->starts_at->diffInMinutes($this->ends_at);
    }

    public function getHoursAttribute(): float
    {
        return $this->minutes / 60;
    }
}

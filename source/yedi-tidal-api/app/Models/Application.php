<?php

namespace App\Models;

use App\Enums\ApplicationStatus;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;
use OwenIt\Auditing\Auditable;
use OwenIt\Auditing\Contracts\Auditable as AuditableContract;

class Application extends Model implements AuditableContract
{
    use Auditable, HasFactory, SoftDeletes;

    protected $fillable = [
        'applicant_id',
        'advert_id',
        'status',
        'actioned_at',
        'rating',
    ];

    protected function casts(): array
    {
        return [
            'status' => ApplicationStatus::class,
            'actioned_at' => 'datetime',
        ];
    }

    /** @return BelongsTo<Applicant, Application>  */
    public function applicant()
    {
        return $this->belongsTo(Applicant::class);
    }

    /** @return BelongsTo<Advert, Application>  */
    public function advert()
    {
        return $this->belongsTo(Advert::class);
    }
}

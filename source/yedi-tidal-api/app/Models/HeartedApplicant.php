<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;
use OwenIt\Auditing\Auditable;
use OwenIt\Auditing\Contracts\Auditable as AuditableContract;

class HeartedApplicant extends Model implements AuditableContract
{
    use Auditable, SoftDeletes;

    protected $fillable = [
        'advertiser_id',
        'applicant_id',
        'deleted_at',
    ];

    /** @return BelongsTo<Advertiser, HeartedApplicant>  */
    public function advertiser()
    {
        return $this->belongsTo(Advertiser::class);
    }

    /** @return BelongsTo<Applicant, HeartedApplicant>  */
    public function applicant()
    {
        return $this->belongsTo(Applicant::class);
    }
}

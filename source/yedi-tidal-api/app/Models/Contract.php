<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\MorphTo;
use Illuminate\Database\Eloquent\SoftDeletes;
use OwenIt\Auditing\Auditable;
use OwenIt\Auditing\Contracts\Auditable as AuditableContract;

class Contract extends Model implements AuditableContract
{
    use Auditable, HasFactory, SoftDeletes;

    protected $fillable = [
        'title',
    ];

    /** @return MorphTo<Advertiser|Applicant, Contract>  */
    public function owner()
    {
        return $this->morphTo('owner');
    }

    /** @return BelongsTo<Upload, Contract>  */
    public function upload()
    {
        return $this->belongsTo(Upload::class);
    }
}

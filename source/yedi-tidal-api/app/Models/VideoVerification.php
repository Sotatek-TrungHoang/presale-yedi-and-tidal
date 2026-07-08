<?php

namespace App\Models;

use App\Models\Interfaces\ImplementsUploads;
use App\Models\Traits\HasUploads;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;
use OwenIt\Auditing\Auditable;
use OwenIt\Auditing\Contracts\Auditable as AuditableContract;

class VideoVerification extends Model implements AuditableContract, ImplementsUploads
{
    use Auditable, HasUploads, SoftDeletes;

    protected $fillable = [
        'code',
    ];

    protected static function booted()
    {
        static::creating(function (self $model) {
            if (! $model->code) {
                $model->code = str_pad(mt_rand(0, 999999), 6, '0', STR_PAD_LEFT);
            }
        });
    }

    /** @return BelongsTo<Applicant, VideoVerification>  */
    public function applicant()
    {
        return $this->belongsTo(Applicant::class);
    }

    /** @return BelongsTo<Upload, VideoVerification>  */
    public function upload()
    {
        return $this->belongsTo(Upload::class);
    }
}

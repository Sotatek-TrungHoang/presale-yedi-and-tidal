<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Str;
use OwenIt\Auditing\Auditable;
use OwenIt\Auditing\Contracts\Auditable as AuditableContract;

class Payslip extends Model implements AuditableContract
{
    use Auditable, HasFactory, SoftDeletes;

    protected $fillable = [
        'title',
    ];

    protected static function booted()
    {
        static::creating(function (self $model) {
            $model->payslip_number = Str::uuid(); // temporary
        });
        static::created(function (self $model) {
            $model->payslip_number = '#'.Str::padLeft($model->id, 6, '0');
            $model->save();
        });
    }

    public function advert()
    {
        return $this->belongsTo(Advert::class);
    }

    public function applicant()
    {
        return $this->belongsTo(Applicant::class);
    }

    /** @return BelongsTo<Upload, Invoice>  */
    public function upload()
    {
        return $this->belongsTo(Upload::class);
    }
}

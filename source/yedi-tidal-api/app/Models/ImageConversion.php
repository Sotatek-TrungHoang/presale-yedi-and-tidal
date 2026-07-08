<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\URL;
use OwenIt\Auditing\Auditable;
use OwenIt\Auditing\Contracts\Auditable as AuditableContract;

class ImageConversion extends Model implements AuditableContract
{
    use Auditable, HasFactory, HasUuids, SoftDeletes;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'conversion_name',
        'path',
        'disk',
        'name',
        'file_name',
        'mime_type',
        'extension',
        'size',
        'width',
        'height',
    ];

    protected static function booted()
    {
        static::deleting(function (self $model) {
            try {
                Storage::disk($model->disk)->delete($model->path);
            } catch (\Throwable $th) {
                //
            }
        });
    }

    public function upload(): BelongsTo
    {
        return $this->belongsTo(Upload::class);
    }

    public function getUrlAttribute(): string
    {
        return URL::signedRoute('common.image-conversions.serve', ['imageConversion' => $this]);
    }
}

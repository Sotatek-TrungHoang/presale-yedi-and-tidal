<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\MorphTo;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\URL;
use Illuminate\Support\Str;
use OwenIt\Auditing\Auditable;
use OwenIt\Auditing\Contracts\Auditable as AuditableContract;

class Upload extends Model implements AuditableContract
{
    use Auditable, HasFactory, HasUuids, SoftDeletes;

    protected const EXPIRE_MINS = 10;

    /**
     * The attributes that are mass assignable.
     *
     * @var array<int, string>
     */
    protected $fillable = [
        'id',
        'disk',
        'file_path',
        'file_name',
        'mime_type',
        'extension',
        'size',
        'image_width',
        'image_height',
        'expires_at',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected $casts = [
        'expires_at' => 'datetime',
    ];

    protected static function booted()
    {
        static::creating(function (self $model) {
            if (! $model->expires_at) { // @phpstan-ignore-line
                $model->expires_at = Carbon::now()->addMinutes(self::EXPIRE_MINS);
            }
            if (! $model->uploaded_by_id) {
                $model->uploadedBy()->associate(Auth::user());
            }
        });

        static::deleting(function (self $model) {
            try {
                Storage::disk($model->disk)->deleteDirectory(
                    Str::of($model->file_path)->explode(DIRECTORY_SEPARATOR)->slice(0, -1)->join(DIRECTORY_SEPARATOR, DIRECTORY_SEPARATOR)
                );
            } catch (\Throwable $th) {
                //
            }
        });
    }

    public function owner(): MorphTo
    {
        return $this->morphTo();
    }

    public function uploadedBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'uploaded_by_id');
    }

    public function conversions(): HasMany
    {
        return $this->hasMany(ImageConversion::class);
    }

    public function getUrlAttribute(): string
    {
        return URL::signedRoute('common.uploads.serve', ['upload' => $this]);
    }
}

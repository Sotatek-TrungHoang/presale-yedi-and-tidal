<?php

namespace App\Models;

use App\Models\Interfaces\ImplementsUploads;
use App\Models\Traits\HasUploads;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;
use OwenIt\Auditing\Auditable;
use OwenIt\Auditing\Contracts\Auditable as AuditableContract;

class Declaration extends Model implements AuditableContract, ImplementsUploads
{
    use Auditable, HasFactory, HasUploads, SoftDeletes;

    protected $fillable = [
        'title',
        'description',
        'time_to_complete',
        'required',
        'upload_id',
    ];

    protected function casts(): array
    {
        return [
            'required' => 'boolean',
        ];
    }

    /** @return BelongsTo<Upload, Declaration>  */
    public function upload()
    {
        return $this->belongsTo(Upload::class);
    }

    /** @return HasMany<DeclarationAgreement, Declaration>  */
    public function declarationAgreements()
    {
        return $this->hasMany(DeclarationAgreement::class);
    }
}

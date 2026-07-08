<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;
use OwenIt\Auditing\Auditable;
use OwenIt\Auditing\Contracts\Auditable as AuditableContract;

class RequiredEvidence extends Model implements AuditableContract
{
    use Auditable, HasFactory, SoftDeletes;

    protected $fillable = [
        'title',
        'time_to_complete',
        'required',
    ];

    protected function casts(): array
    {
        return [
            'required' => 'boolean',
        ];
    }

    /** @return HasMany<ApplicantEvidence, RequiredEvidence>  */
    public function applicantEvidence()
    {
        return $this->hasMany(ApplicantEvidence::class);
    }
}

<?php

namespace App\Models;

use App\Models\Interfaces\ImplementsUploads;
use App\Models\Traits\HasUploads;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;
use OwenIt\Auditing\Auditable;
use OwenIt\Auditing\Contracts\Auditable as AuditableContract;

class ApplicantEvidence extends Model implements AuditableContract, ImplementsUploads
{
    use Auditable, HasFactory, HasUploads, SoftDeletes;

    protected $fillable = [];

    /** @return BelongsTo<Applicant, Declaration>  */
    public function applicant()
    {
        return $this->belongsTo(Applicant::class);
    }

    /** @return BelongsTo<RequiredEvidence, ApplicantEvidence>  */
    public function requiredEvidence()
    {
        return $this->belongsTo(RequiredEvidence::class);
    }

    /** @return BelongsTo<Upload, ApplicantEvidence>  */
    public function upload()
    {
        return $this->belongsTo(Upload::class);
    }
}

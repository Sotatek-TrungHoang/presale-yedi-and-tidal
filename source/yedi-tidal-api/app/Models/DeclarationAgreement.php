<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;
use OwenIt\Auditing\Auditable;
use OwenIt\Auditing\Contracts\Auditable as AuditableContract;

class DeclarationAgreement extends Model implements AuditableContract
{
    use Auditable, HasFactory, SoftDeletes;

    protected $fillable = [];

    /** @return BelongsTo<Declaration, DeclarationAgreement>  */
    public function declaration()
    {
        return $this->belongsTo(Declaration::class);
    }

    /** @return BelongsTo<Applicant, Declaration>  */
    public function applicant()
    {
        return $this->belongsTo(Applicant::class);
    }
}

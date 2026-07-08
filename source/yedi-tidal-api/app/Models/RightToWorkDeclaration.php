<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;
use OwenIt\Auditing\Auditable;
use OwenIt\Auditing\Contracts\Auditable as AuditableContract;

class RightToWorkDeclaration extends Model implements AuditableContract
{
    use Auditable, HasFactory, SoftDeletes;

    protected $fillable = [
        'right_to_work_uk',
        'require_visa_to_work_uk',
        'lived_or_worked_outside_uk_6_months',
        'has_criminal_convictions_or_prosecutions_pending',
    ];

    protected function casts(): array
    {
        return [
            'right_to_work_uk' => 'boolean',
            'require_visa_to_work_uk' => 'boolean',
            'lived_or_worked_outside_uk_6_months' => 'boolean',
            'has_criminal_convictions_or_prosecutions_pending' => 'boolean',
        ];
    }

    /** @return BelongsTo<Applicant, RightToWorkDeclaration>  */
    public function applicant()
    {
        return $this->belongsTo(Applicant::class);
    }
}

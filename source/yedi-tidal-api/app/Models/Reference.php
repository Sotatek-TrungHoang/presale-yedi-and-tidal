<?php

namespace App\Models;

use App\Enums\ReferenceRating;
use App\Enums\ReferenceStatus;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Support\Str;
use OwenIt\Auditing\Auditable;
use OwenIt\Auditing\Contracts\Auditable as AuditableContract;

class Reference extends Model implements AuditableContract
{
    use Auditable;

    protected $fillable = [
        'name',
        'telephone',
        'email',
        'status',
        'job_title',
        'employment_start_date',
        'employment_end_date',
        'advertiser_name',
        'referee_name',
        'referee_job_title',
        'relationship_to_applicant',
        'how_long_has_known_applicant',
        'comments',
        'curriculum_knowledge',
        'ability_to_support_groups',
        'ability_to_support_on_1_1_basis',
        'relationships_with_colleagues',
        'rapport_with_students',
        'pupil_management',
        'communication_and_attitude',
        'reliability_and_punctuality',
        'additional_comments',
        'any_disciplinary_procedures',
        'was_dismissed',
        'would_reemploy',
        'would_reemploy_reason',
        'not_suitable_to_work_with_under_18s',
        'may_share_with_new_employers',
        'signature_name',
        'signature_date',
        'signature',
    ];

    protected $casts = [
        'status' => ReferenceStatus::class,
        'employment_start_date' => 'date',
        'employment_end_date' => 'date',
        'curriculum_knowledge' => ReferenceRating::class,
        'ability_to_support_groups' => ReferenceRating::class,
        'ability_to_support_on_1_1_basis' => ReferenceRating::class,
        'relationships_with_colleagues' => ReferenceRating::class,
        'rapport_with_students' => ReferenceRating::class,
        'pupil_management' => ReferenceRating::class,
        'communication_and_attitude' => ReferenceRating::class,
        'reliability_and_punctuality' => ReferenceRating::class,
        'any_disciplinary_procedures' => 'boolean',
        'was_dismissed' => 'boolean',
        'would_reemploy' => 'boolean',
        'not_suitable_to_work_with_under_18s' => 'boolean',
        'may_share_with_new_employers' => 'boolean',
        'signature_date' => 'datetime',
    ];

    public static function booted()
    {
        static::creating(function (self $reference) {
            $reference->reference_id = Str::uuid()->toString();
        });
    }

    /** @return BelongsTo<Applicant, Reference>  */
    public function applicant()
    {
        return $this->belongsTo(Applicant::class);
    }

    /** @return BelongsTo<Upload, Reference>  */
    public function upload()
    {
        return $this->belongsTo(Upload::class);
    }
}

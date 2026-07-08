<?php

namespace App\Models;

use App\Enums\ApplicantComplianceStatus;
use App\Enums\ApplicantQualification;
use App\Enums\ProfileStatus;
use App\Handlers\Notifications\NotifyApplicantHandler;
use App\Models\Interfaces\ImplementsAddresses;
use App\Models\Interfaces\ImplementsUploads;
use App\Models\Traits\HasAddresses;
use App\Models\Traits\HasUploads;
use App\Notifications\Applicant\AccountActiveNotification;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\Relations\HasOne;
use Illuminate\Database\Eloquent\Relations\MorphMany;
use Illuminate\Database\Eloquent\SoftDeletes;
use OwenIt\Auditing\Auditable;
use OwenIt\Auditing\Contracts\Auditable as AuditableContract;

class Applicant extends Model implements AuditableContract, ImplementsAddresses, ImplementsUploads
{
    use Auditable, HasAddresses, HasFactory, HasUploads, SoftDeletes;

    protected $fillable = [
        'compliance_status',
        'profile_status',
        'teacher_number',
        'qualification',
        'photograph_id',
        'evidence_of_id_id',
        'type_of_work_id',
        'job_role_id',
        'address_id',
        'video_verification_id',
        'rating',
        'sign_up_completed_at',
    ];

    protected function casts(): array
    {
        return [
            'profile_status' => ProfileStatus::class,
            'compliance_status' => ApplicantComplianceStatus::class,
            'qualification' => ApplicantQualification::class,
            'rating' => 'float',
            'sign_up_completed_at' => 'datetime',
        ];
    }

    protected static function booted()
    {
        static::updated(function (self $model) {
            if ($model->isDirty('profile_status') && $model->profile_status === ProfileStatus::Active) {
                /** @var NotifyApplicantHandler $notifyApplicantHandler */
                $notifyApplicantHandler = app()->make(NotifyApplicantHandler::class);
                $notifyApplicantHandler->handle($model, new AccountActiveNotification);
            }
        });
    }

    /** @return MorphOne<User, Applicant>  */
    public function user()
    {
        return $this->morphOne(User::class, 'userable');
    }

    /** @return HasMany<Application, Applicant>  */
    public function applications()
    {
        return $this->hasMany(Application::class);
    }

    /** @return BelongsToMany<Advert, Applicant>  */
    public function appliedAdverts()
    {
        return $this->belongsToMany(Advert::class, 'applications');
    }

    /** @return HasMany<Reference, Applicant>  */
    public function references()
    {
        return $this->hasMany(Reference::class);
    }

    /** @return HasMany<DeclarationAgreement, Applicant>  */
    public function declarationAgreements()
    {
        return $this->hasMany(DeclarationAgreement::class);
    }

    /** @return HasOne<RightToWorkDeclaration, Applicant>  */
    public function rightToWorkDeclaration()
    {
        return $this->hasOne(RightToWorkDeclaration::class);
    }

    /** @return HasMany<ApplicantEvidence, Applicant>  */
    public function applicantEvidence()
    {
        return $this->hasMany(ApplicantEvidence::class);
    }

    /** @return HasMany<VideoVerification, Applicant>  */
    public function videoVerifications()
    {
        return $this->hasMany(VideoVerification::class);
    }

    /** @return BelongsTo<Upload, Applicant>  */
    public function photograph()
    {
        return $this->belongsTo(Upload::class, 'photograph_id');
    }

    /** @return BelongsTo<Upload, Applicant>  */
    public function evidenceOfId()
    {
        return $this->belongsTo(Upload::class, 'evidence_of_id_id');
    }

    /** @return BelongsTo<VideoVerification, Applicant>  */
    public function videoVerification()
    {
        return $this->belongsTo(VideoVerification::class);
    }

    /** @return BelongsTo<Address, Applicant>  */
    public function address()
    {
        return $this->belongsTo(Address::class);
    }

    /** @return HasMany<Payslip, Applicant>  */
    public function payslips()
    {
        return $this->hasMany(Payslip::class);
    }

    /** @return MorphMany<Contract, Applicant>  */
    public function contracts()
    {
        return $this->morphMany(Contract::class, 'owner');
    }

    /** @return HasMany<HeartedApplicant, Applicant>  */
    public function heartedApplicants()
    {
        return $this->hasMany(HeartedApplicant::class);
    }

    /** @return BelongsTo<TypeOfWork, Applicant>  */
    public function typeOfWork()
    {
        return $this->belongsTo(TypeOfWork::class);
    }

    /** @return BelongsTo<JobRole, Applicant>  */
    public function jobRole()
    {
        return $this->belongsTo(JobRole::class);
    }
}

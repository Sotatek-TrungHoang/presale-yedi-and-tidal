<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use OwenIt\Auditing\Auditable;
use OwenIt\Auditing\Contracts\Auditable as AuditableContract;

class Settings extends Model implements AuditableContract
{
    use Auditable;

    protected $table = 'settings';

    protected $fillable = [
        'references_required',
        'require_teacher_number',
        'default_applicant_charge_percentage',
        'default_advertiser_charge_percentage',
        'invoice_due_date_days',
        'invoice_late_payment_charge_percent',
        'invoice_payment_account_name',
        'invoice_payment_account_number',
        'invoice_payment_account_sort_code',
        'invoice_contact_address',
        'invoice_contact_email',
        'invoice_contact_telephone',
        'applicant_contract',
        'advertiser_contract',
    ];

    protected $casts = [
        'require_teacher_number' => 'boolean',
        'default_applicant_charge_percentage' => 'float',
        'default_advertiser_charge_percentage' => 'float',
        'invoice_late_payment_charge_percent' => 'float',
    ];

    protected $visible = [
        'references_required',
        'require_teacher_number',
    ];
}

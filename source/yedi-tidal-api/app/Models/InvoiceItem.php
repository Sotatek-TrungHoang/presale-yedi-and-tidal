<?php

namespace App\Models;

use App\Casts\MoneyCast;
use App\Enums\PayType;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\SoftDeletes;
use OwenIt\Auditing\Auditable;
use OwenIt\Auditing\Contracts\Auditable as AuditableContract;

class InvoiceItem extends Model implements AuditableContract
{
    use Auditable, HasFactory, SoftDeletes;

    protected $guarded = [
        'id',
    ];

    protected $casts = [
        'date' => 'date',
        'quantity' => 'float',
        'rate_type' => PayType::class,
        'rate' => MoneyCast::class,
        'amount' => MoneyCast::class,
    ];

    public function invoice()
    {
        return $this->belongsTo(Invoice::class);
    }
}

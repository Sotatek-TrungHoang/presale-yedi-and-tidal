<?php

namespace App\Models;

use App\Casts\MoneyCast;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\SoftDeletes;
use Illuminate\Support\Str;
use OwenIt\Auditing\Auditable;
use OwenIt\Auditing\Contracts\Auditable as AuditableContract;

class Invoice extends Model implements AuditableContract
{
    use Auditable, HasFactory, SoftDeletes;

    protected $fillable = [
        'title',
        'due_date',
        'invoice_due_date_days',
        'invoice_late_payment_charge_percent',
        'sub_total',
        'vat',
        'total',
    ];

    protected $casts = [
        'due_date' => 'datetime',
        'sub_total' => MoneyCast::class,
        'vat' => MoneyCast::class,
        'total' => MoneyCast::class,
    ];

    protected static function booted()
    {
        static::creating(function (self $model) {
            $model->invoice_number = Str::uuid(); // temporary
        });
        static::created(function (self $model) {
            $model->invoice_number = 'INV'.Str::padLeft($model->id, 6, '0');
            $model->save();
        });
    }

    public function advert()
    {
        return $this->belongsTo(Advert::class);
    }

    /** @return BelongsTo<Upload, Invoice>  */
    public function upload()
    {
        return $this->belongsTo(Upload::class);
    }

    public function items()
    {
        return $this->hasMany(InvoiceItem::class);
    }
}

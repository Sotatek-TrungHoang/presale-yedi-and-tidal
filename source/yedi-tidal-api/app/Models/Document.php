<?php

namespace App\Models;

use App\Models\Interfaces\ImplementsUploads;
use App\Models\Traits\HasUploads;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\MorphTo;
use Illuminate\Database\Eloquent\SoftDeletes;
use OwenIt\Auditing\Auditable;
use OwenIt\Auditing\Contracts\Auditable as AuditableContract;

class Document extends Model implements AuditableContract, ImplementsUploads
{
    use Auditable, HasUploads, SoftDeletes;

    protected $fillable = ['title', 'owner_type', 'owner_id', 'upload_id'];

    /** @return MorphTo<Advert, Document>  */
    public function owner()
    {
        return $this->morphTo();
    }

    public function upload()
    {
        return $this->belongsTo(Upload::class);
    }
}

<?php

namespace App\Models\Traits;

use App\Models\Upload;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\MorphMany;

/**
 * @mixin Model
 */
trait HasUploads
{
    public function uploads(): MorphMany
    {
        return $this->morphMany(Upload::class, 'owner');
    }
}

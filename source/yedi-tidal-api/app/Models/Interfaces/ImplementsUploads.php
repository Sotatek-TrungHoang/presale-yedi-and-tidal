<?php

namespace App\Models\Interfaces;

use Illuminate\Database\Eloquent\Relations\MorphMany;

interface ImplementsUploads
{
    public function uploads(): MorphMany;
}

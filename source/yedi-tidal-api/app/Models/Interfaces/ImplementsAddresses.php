<?php

namespace App\Models\Interfaces;

use Illuminate\Database\Eloquent\Relations\MorphMany;

interface ImplementsAddresses
{
    public function addresses(): MorphMany;
}

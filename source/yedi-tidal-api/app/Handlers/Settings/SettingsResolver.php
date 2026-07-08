<?php

namespace App\Handlers\Settings;

use App\Models\Settings;
use Illuminate\Database\Eloquent\ModelNotFoundException;
use InvalidArgumentException;

class SettingsResolver
{
    /**
     * @return Settings
     *
     * @throws InvalidArgumentException
     * @throws ModelNotFoundException
     */
    public function resolve()
    {
        return Settings::query()->latest()->firstOrFail();
    }
}

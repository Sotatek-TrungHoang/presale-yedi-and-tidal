<?php

namespace App\Http\Controllers\Common;

use App\Handlers\Settings\SettingsResolver;
use App\Http\Controllers\Controller;

class SettingsController extends Controller
{
    public function __construct(
        protected SettingsResolver $settingsResolver
    ) {}

    public function __invoke()
    {
        $settings = $this->settingsResolver->resolve();

        return $this->stdSuccess(data: $settings);
    }
}

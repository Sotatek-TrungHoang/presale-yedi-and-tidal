<?php

namespace App\DTOs\Uploads;

use Spatie\Image\Enums\Fit;
use Spatie\LaravelData\Data;

class ImageConversionOptions extends Data
{
    public function __construct(
        public ?int $width,
        public ?int $height,
        public Fit $fit,
    ) {}
}

<?php

namespace App\Enums;

use App\DTOs\Uploads\ImageConversionOptions;
use Spatie\Image\Enums\Fit;

enum ImageConversionType: string
{
    case Thumbnail = 'thumbnail';
    case Small = 'small';
    case Medium = 'medium';
    case Large = 'large';

    public function getOptions(int $width, int $height): ?ImageConversionOptions
    {
        switch ($this) {
            case self::Thumbnail:
                return new ImageConversionOptions(128, 128, Fit::Contain);
            case self::Small:
                return $this->calculateSize(500, $width, $height);
            case self::Medium:
                return $this->calculateSize(720, $width, $height);
            case self::Large:
                return $this->calculateSize(1024, $width, $height);
        }
    }

    private function calculateSize(int $longestEdge, int $width, int $height): ?ImageConversionOptions
    {
        $landscape = $width > $height;
        if (($landscape && $width < $longestEdge) || (! $landscape && $height < $longestEdge)) {
            return null;
        }

        // $ratio = $width / $height;

        if ($landscape) {
            return new ImageConversionOptions(
                width: $longestEdge,
                height: null,
                // height: (int) floor($longestEdge / $ratio),
                fit: Fit::Fill
            );
        }

        return new ImageConversionOptions(
            width: null,
            // width: (int) floor($longestEdge * $ratio),
            height: $longestEdge,
            fit: Fit::Fill
        );

    }
}

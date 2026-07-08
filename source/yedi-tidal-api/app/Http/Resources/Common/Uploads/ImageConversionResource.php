<?php

namespace App\Http\Resources\Common\Uploads;

use App\Models\ImageConversion;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin ImageConversion
 *
 * @property ImageConversion $resource
 */
class ImageConversionResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'width' => $this->width,
            'height' => $this->height,
            'url' => $this->url,
        ];
    }
}

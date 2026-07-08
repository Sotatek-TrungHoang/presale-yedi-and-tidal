<?php

namespace App\Http\Resources\Common\Uploads;

use App\Models\Upload;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Collection;

/**
 * @mixin Upload
 *
 * @property Upload $resource
 */
class UploadResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'file_name' => $this->file_name,
            'mime_type' => $this->mime_type,
            'extension' => $this->extension,
            'size' => $this->size,
            'url' => $this->url,
            'conversions' => $this->conversions()
                ->get()
                ->groupBy('conversion_name')
                ->map(fn (Collection $conversions) => new ImageConversionResource($conversions->first())),
            'created_at' => $this->created_at,
        ];
    }
}

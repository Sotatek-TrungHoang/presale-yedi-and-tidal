<?php

namespace App\Http\Resources\Common\Documents;

use App\Http\Resources\Common\Uploads\UploadResource;
use App\Models\Document;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin Document
 *
 * @property Document $resource
 */
class DocumentResource extends JsonResource
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
            'title' => $this->title,
            'upload' => new UploadResource($this->upload),
        ];
    }
}

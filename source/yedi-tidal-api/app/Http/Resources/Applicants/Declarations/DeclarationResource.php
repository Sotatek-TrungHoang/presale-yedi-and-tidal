<?php

namespace App\Http\Resources\Applicants\Declarations;

use App\Http\Resources\Common\Uploads\UploadResource;
use App\Models\Declaration;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin Declaration
 *
 * @property Declaration $resource
 */
class DeclarationResource extends JsonResource
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
            'description' => $this->description,
            'time_to_complete' => $this->time_to_complete,
            'required' => $this->required,
            'upload' => new UploadResource($this->upload),
        ];
    }
}

<?php

namespace App\Http\Resources\Applicants\References;

use App\Models\Reference;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin Reference
 *
 * @property Reference $resource
 */
class ReferenceResource extends JsonResource
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
            'name' => $this->name,
            'email' => $this->email,
            'telephone' => $this->telephone,
            'status' => $this->status->value,
            'status_label' => $this->status->getLabel(),
        ];
    }
}

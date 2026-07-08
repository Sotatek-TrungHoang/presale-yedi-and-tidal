<?php

namespace App\Http\Resources\Applicants\Evidence;

use App\Models\RequiredEvidence;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin RequiredEvidence
 *
 * @property RequiredEvidence $resource
 */
class RequiredEvidenceResource extends JsonResource
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
            'time_to_complete' => $this->time_to_complete,
            'required' => $this->required,
        ];
    }
}

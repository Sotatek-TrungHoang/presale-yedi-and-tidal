<?php

namespace App\Http\Resources\Applicants\Evidence;

use App\Http\Resources\Common\Uploads\UploadResource;
use App\Models\ApplicantEvidence;
use App\Models\RequiredEvidence;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin ApplicantEvidence
 *
 * @property RequiredEvidence $resource
 */
class ApplicantEvidenceResource extends JsonResource
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
            'upload' => new UploadResource($this->upload),
            'required_evidence' => new RequiredEvidenceResource($this->requiredEvidence),
        ];
    }
}

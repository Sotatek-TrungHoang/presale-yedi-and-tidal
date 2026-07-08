<?php

namespace App\Http\Resources\Applicants\HeartedApplicants;

use App\Http\Resources\Applicants\ApplicantResource;
use App\Models\HeartedApplicant;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin HeartedApplicant
 *
 * @property HeartedApplicant $resource
 */
class HeartedApplicantResource extends JsonResource
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
            'applicant' => new ApplicantResource($this->applicant),
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}

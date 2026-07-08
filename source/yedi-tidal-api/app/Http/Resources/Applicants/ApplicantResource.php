<?php

namespace App\Http\Resources\Applicants;

use App\Http\Resources\Common\Addresses\AddressResource;
use App\Http\Resources\Common\Uploads\UploadResource;
use App\Http\Resources\Common\UserResource;
use App\Models\Applicant;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin Applicant
 *
 * @property Applicant $resource
 */
class ApplicantResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        /** @var User|null $user */
        $user = $request->user();

        return [
            'id' => $this->id,
            'compliance_status' => $this->compliance_status->value,
            'compliance_status_label' => $this->compliance_status->getLabel(),
            'qualification' => $this->qualification?->value,
            'qualification_label' => $this->qualification?->label(),
            'teacher_number' => $this->teacher_number,
            'rating' => $this->rating,
            'user' => new UserResource($this->whenLoaded('user')),
            $this->mergeWhen($user?->isAdmin() || $user->userable()->is($this->resource), fn () => [
                'address' => new AddressResource($this->whenLoaded('address')),
            ]),
            'photograph' => new UploadResource($this->whenLoaded('photograph')),
            $this->mergeWhen($user?->isAdvertiser(), fn () => [
                'hearted' => $this->heartedApplicants()->where('advertiser_id', $user->userable_id)->exists(),
            ]),
            'created_at' => $this->created_at,
        ];
    }
}

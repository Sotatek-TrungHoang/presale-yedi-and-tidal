<?php

namespace App\Http\Resources\Applications;

use App\Http\Resources\Adverts\AdvertResource;
use App\Http\Resources\Applicants\ApplicantResource;
use App\Models\Application;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin Application
 *
 * @property Application $resource
 */
class ApplicationResource extends JsonResource
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
            'status' => $this->status->value,
            'status_label' => $this->status->getLabel(),
            'applicant_id' => $this->applicant_id,
            'applicant' => new ApplicantResource($this->whenLoaded('applicant')),
            'advert_id' => $this->advert_id,
            'advert' => new AdvertResource($this->whenLoaded('advert')),
            'rating' => $this->rating,
            'can_rate' => $request->user()->can('rate', $this->resource),
            'actioned_at' => $this->actioned_at,
            'created_at' => $this->created_at,
        ];
    }
}

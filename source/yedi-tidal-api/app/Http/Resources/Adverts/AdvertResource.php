<?php

namespace App\Http\Resources\Adverts;

use App\Enums\ApplicationStatus;
use App\Enums\UserType;
use App\Http\Resources\Advertisers\AdvertiserResource;
use App\Http\Resources\Applications\ApplicationResource;
use App\Http\Resources\Common\Addresses\AddressResource;
use App\Http\Resources\Common\Documents\DocumentCollection;
use App\Http\Resources\Common\MoneyResource;
use App\Models\Advert;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin Advert
 *
 * @property Advert $resource
 */
class AdvertResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        /** @var User $user */
        $user = $request->user();

        return [
            'id' => $this->id,
            'title' => $this->title,
            'description' => $this->description,
            'type' => $this->type->value,
            'type_label' => $this->type->getLabel(),
            'status' => $this->status->value,
            'status_label' => $this->status->getLabel(),
            'starts_at' => $this->starts_at,
            'ends_at' => $this->ends_at,
            'shift_start_time' => $this->shift_start_time,
            'shift_end_time' => $this->shift_end_time,
            'apply_by' => $this->apply_by,
            'day_to_day_active_minutes' => $this->day_to_day_active_minutes,
            'documents' => new DocumentCollection($this->whenLoaded('documents')),
            'advertiser_pay_rate_type' => $this->advertiser_pay_rate_type->value,
            'advertiser_pay_rate_type_label' => $this->advertiser_pay_rate_type->getLabel(),
            'created_at' => $this->created_at,

            // Advertiser
            $this->mergeWhen($user->type === UserType::Advertiser, [
                'advertiser_pay_rate' => new MoneyResource($this->advertiser_pay_rate),
                'applications_count' => $this->applications()->count(),
                'accepted_application' => new ApplicationResource($this->acceptedApplication?->load(['applicant', 'applicant.photograph', 'applicant.user'])),
                'contact_name' => $this->contact_name,
                'contact_position' => $this->contact_position,
                'contact_email' => $this->contact_email,
                'contact_telephone' => $this->contact_telephone,
            ]),

            // Applicant
            $this->mergeWhen($user->type === UserType::Applicant, [
                'applicant_pay' => new MoneyResource($this->applicant_pay),
                'applicant_pay_rate' => new MoneyResource($this->applicant_pay_rate),
                'application' => new ApplicationResource(
                    $this
                        ->applications()
                        ->where('status', '!=', ApplicationStatus::Cancelled)
                        ->where('applicant_id', $user->userable_id)
                        ->first()
                ),

                $this->mergeWhen($this->acceptedApplication()->where('applicant_id', $user->userable_id)->exists(), [
                    'contact_name' => $this->contact_name,
                    'contact_position' => $this->contact_position,
                    'contact_email' => $this->contact_email,
                    'contact_telephone' => $this->contact_telephone,
                ]),

            ]),

            // Relationships
            'advertiser' => new AdvertiserResource($this->advertiser),
            'address' => new AddressResource($this->address),

        ];
    }
}

<?php

namespace App\Http\Resources\Common\Addresses;

use App\Models\Address;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin Address
 *
 * @property Address $resource
 */
class AddressResource extends JsonResource
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
            'formatted' => $this->formatted,
            'line_1' => $this->line_1,
            'line_2' => $this->line_2,
            'town_city' => $this->town_city,
            'country' => $this->country['alpha2'],
            'country_label' => $this->country['name'],
            'postcode' => $this->postcode,
            'latitude' => $this->latitude,
            'longitude' => $this->longitude,
        ];
    }
}

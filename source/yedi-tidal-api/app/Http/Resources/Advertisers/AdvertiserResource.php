<?php

namespace App\Http\Resources\Advertisers;

use App\Http\Resources\Common\Uploads\UploadResource;
use App\Models\Advertiser;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin Advertiser
 *
 * @property Advertiser $resource
 */
class AdvertiserResource extends JsonResource
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
            'bio' => $this->bio,
            'email' => $this->email,
            'telephone' => $this->telephone,
            'additional_info' => $this->additional_info,
            'photograph' => new UploadResource($this->photograph),
            'created_at' => $this->created_at,
        ];
    }
}

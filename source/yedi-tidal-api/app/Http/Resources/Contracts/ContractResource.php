<?php

namespace App\Http\Resources\Contracts;

use App\Http\Resources\Common\Uploads\UploadResource;
use App\Models\Contract;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin Contract
 *
 * @property Contract $resource
 */
class ContractResource extends JsonResource
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
            'upload' => new UploadResource($this->upload),
            'created_at' => $this->created_at,
        ];
    }
}

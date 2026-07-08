<?php

namespace App\Http\Resources\Applicants\TypesOfWork;

use App\Models\TypeOfWork;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin TypeOfWork
 *
 * @property TypeOfWork $resource
 */
class TypeOfWorkResource extends JsonResource
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
        ];
    }
}

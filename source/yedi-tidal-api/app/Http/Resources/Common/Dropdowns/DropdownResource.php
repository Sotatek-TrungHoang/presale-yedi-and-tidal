<?php

namespace App\Http\Resources\Common\Dropdowns;

use App\DTOs\Dropdowns\DropdownValue;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin DropdownValue
 *
 * @property DropdownValue $resource
 */
class DropdownResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'value' => $this->value,
            'label' => $this->label,
            'extra' => $this->when($this->resource->extra !== null, $this->resource->extra),
        ];
    }
}

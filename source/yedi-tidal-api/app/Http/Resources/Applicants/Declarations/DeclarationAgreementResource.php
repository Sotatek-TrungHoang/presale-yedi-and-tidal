<?php

namespace App\Http\Resources\Applicants\Declarations;

use App\Models\DeclarationAgreement;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin DeclarationAgreement
 *
 * @property DeclarationAgreement $resource
 */
class DeclarationAgreementResource extends JsonResource
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
            'declaration' => new DeclarationResource($this->declaration),
        ];
    }
}

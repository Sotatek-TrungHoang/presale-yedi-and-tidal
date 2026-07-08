<?php

namespace App\Http\Resources\Applicants\RightToWorkDeclarations;

use App\Models\RightToWorkDeclaration;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin RightToWorkDeclaration
 *
 * @property RightToWorkDeclaration $resource
 */
class RightToWorkDeclarationResource extends JsonResource
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
            'right_to_work_uk' => $this->right_to_work_uk,
            'require_visa_to_work_uk' => $this->require_visa_to_work_uk,
            'lived_or_worked_outside_uk_6_months' => $this->lived_or_worked_outside_uk_6_months,
            'has_criminal_convictions_or_prosecutions_pending' => $this->has_criminal_convictions_or_prosecutions_pending,
        ];
    }
}

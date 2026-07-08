<?php

namespace App\Http\Resources\Payslips;

use App\Http\Resources\Common\Uploads\UploadResource;
use App\Models\Payslip;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin Payslip
 *
 * @property Payslip $resource
 */
class PayslipResource extends JsonResource
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
            'payslip_number' => $this->payslip_number,
            'title' => $this->title,
            'upload' => new UploadResource($this->upload),
            'created_at' => $this->created_at,
        ];
    }
}

<?php

namespace App\Http\Resources\Invoices;

use App\Http\Resources\Common\Uploads\UploadResource;
use App\Models\Invoice;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin Invoice
 *
 * @property Invoice $resource
 */
class InvoiceResource extends JsonResource
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
            'invoice_number' => $this->invoice_number,
            'title' => $this->title,
            'upload' => new UploadResource($this->upload),
            'created_at' => $this->created_at,
        ];
    }
}

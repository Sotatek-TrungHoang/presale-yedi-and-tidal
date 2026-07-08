<?php

namespace App\Http\Resources\Applicants\VideoVerifications;

use App\Http\Resources\Common\Uploads\UploadResource;
use App\Models\VideoVerification;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin VideoVerification
 *
 * @property VideoVerification $resource
 */
class VideoVerificationResource extends JsonResource
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
            'code' => $this->code,
            'upload' => new UploadResource($this->upload),
        ];
    }
}

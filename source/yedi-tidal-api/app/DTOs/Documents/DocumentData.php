<?php

namespace App\DTOs\Documents;

use App\Models\Upload;
use Spatie\LaravelData\Attributes\MapInputName;
use Spatie\LaravelData\Data;

class DocumentData extends Data
{
    public function __construct(
        public string $title,
        #[MapInputName('upload_id')]
        public Upload $upload,
    ) {}
}

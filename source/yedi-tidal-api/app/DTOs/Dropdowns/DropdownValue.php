<?php

namespace App\DTOs\Dropdowns;

class DropdownValue
{
    public function __construct(
        public string $label,
        public mixed $value,
        public ?array $extra = null,
    ) {}
}

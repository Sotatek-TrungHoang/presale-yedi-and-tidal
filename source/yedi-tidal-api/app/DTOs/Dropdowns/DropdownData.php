<?php

namespace App\DTOs\Dropdowns;

use Illuminate\Support\Arr;

class DropdownData
{
    public function __construct(
        public ?string $search = null,
        public array $additional = []
    ) {}

    /**
     * Get an item from the additional data using "dot" notation.
     *
     * @param  string|int|null  $key
     * @param  mixed  $default
     * @return mixed
     */
    public function getAdditional($key, $default = null)
    {
        return Arr::get($this->additional, $key, $default);
    }

    /**
     * Check if an item or items exist in the additional data using "dot" notation.
     *
     * @param  string|array  $keys
     * @return bool
     */
    public function hasAdditional($keys)
    {
        return Arr::has($this->additional, $keys);
    }
}

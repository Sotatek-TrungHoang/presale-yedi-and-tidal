<?php

namespace App\Registries\Dropdowns;

use App\DTOs\Dropdowns\DropdownData;
use App\DTOs\Dropdowns\DropdownValue;
use Illuminate\Support\Collection;
use Illuminate\Validation\UnauthorizedException;

interface DropdownOptionInterface
{
    public function getId(): string;

    /**
     * @return Collection<array-key, DropdownValue>
     */
    public function getResults(DropdownData $dropdownData): Collection;

    /**
     * @throws UnauthorizedException
     * */
    public function authCheck(): self;
}

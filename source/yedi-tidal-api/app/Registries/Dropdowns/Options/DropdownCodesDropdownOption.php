<?php

namespace App\Registries\Dropdowns\Options;

use App\DTOs\Dropdowns\DropdownData;
use App\DTOs\Dropdowns\DropdownValue;
use App\Registries\Dropdowns\DropdownRegistry;
use Illuminate\Support\Collection;
use Illuminate\Support\Str;

class DropdownCodesDropdownOption extends AbstractDropdownOption
{
    public function getId(): string
    {
        return 'dropdown_codes';
    }

    /**
     * @return Collection<array-key, DropdownValue>
     */
    public function getResults(DropdownData $dropdownData): Collection
    {
        /** @var DropdownRegistry $registry */
        $registry = app()->make(DropdownRegistry::class);

        return collect($registry->ids())
            ->sortKeys()
            ->values()
            ->map(fn (string $id) => new DropdownValue(
                Str::of($id)->replace('_', ' ')->lower()->title()->toString(),
                $id,
            ));
    }
}

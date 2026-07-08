<?php

namespace App\Registries\Dropdowns\Options;

use App\DTOs\Dropdowns\DropdownData;
use App\DTOs\Dropdowns\DropdownValue;
use BackedEnum;
use Illuminate\Support\Collection;
use Illuminate\Support\Str;
use InvalidArgumentException;
use UnitEnum;

abstract class AbstractEnumDropdownOption extends AbstractDropdownOption
{
    /**
     * @return Collection<array-key, DropdownValue>
     */
    public function getEnumResults(DropdownData $dropdownData, string $enumClass, ?string $sortBy = 'label', ?callable $getExtra = null): Collection
    {

        if (! enum_exists($enumClass)) {
            throw new InvalidArgumentException('Non-enum class passed into dropdown option');
        }

        if (! method_exists($enumClass, 'cases')) {
            throw new InvalidArgumentException('Non-enum class passed into dropdown option');
        }

        /** @var UnitEnum[] $cases */
        $cases = call_user_func([$enumClass, 'cases']);

        return collect($cases)
            ->map(function (UnitEnum $unitEnum) use ($getExtra) {

                $value = $unitEnum instanceof BackedEnum
                    ? $unitEnum->value
                    : $unitEnum->name;

                /** @disregard */
                $label = method_exists($unitEnum, 'label')
                    ? $unitEnum->label()
                    : $unitEnum->name;

                return new DropdownValue(label: $label, value: $value, extra: $getExtra ? $getExtra($unitEnum) : null);
            })
            ->filter(fn (DropdownValue $case) => $dropdownData->search ? Str::contains($case->label, $dropdownData->search, true) : true)
            ->sort(fn (DropdownValue $a, DropdownValue $b) => $sortBy ? $a->$sortBy <=> $b->$sortBy : 0)
            ->values();
    }
}

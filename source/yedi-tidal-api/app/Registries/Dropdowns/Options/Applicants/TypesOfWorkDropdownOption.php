<?php

namespace App\Registries\Dropdowns\Options\Applicants;

use App\DTOs\Dropdowns\DropdownData;
use App\DTOs\Dropdowns\DropdownValue;
use App\Models\TypeOfWork;
use App\Registries\Dropdowns\Options\AbstractDropdownOption;
use Illuminate\Support\Collection;

class TypesOfWorkDropdownOption extends AbstractDropdownOption
{
    public function getId(): string
    {
        return 'types_of_work';
    }

    public function public(): bool
    {
        return true;
    }

    /**
     * @return Collection<array-key, DropdownValue>
     */
    public function getResults(DropdownData $dropdownData): Collection
    {
        return TypeOfWork::query()
            ->orderBy('name')
            ->get()
            ->map(function (TypeOfWork $typeOfWork) {
                return new DropdownValue(label: $typeOfWork->name, value: $typeOfWork->id);
            });
    }
}

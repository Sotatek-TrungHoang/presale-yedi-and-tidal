<?php

namespace App\Registries\Dropdowns\Options\Users;

use App\DTOs\Dropdowns\DropdownData;
use App\DTOs\Dropdowns\DropdownValue;
use App\Enums\UserTitle;
use App\Registries\Dropdowns\Options\AbstractEnumDropdownOption;
use Illuminate\Support\Collection;

class UserTitlesDropdownOption extends AbstractEnumDropdownOption
{
    public function getId(): string
    {
        return 'user_titles';
    }

    /**
     * @return Collection<array-key, DropdownValue>
     */
    public function getResults(DropdownData $dropdownData): Collection
    {
        return $this->getEnumResults($dropdownData, UserTitle::class);
    }

    public function public(): bool
    {
        return true;
    }
}

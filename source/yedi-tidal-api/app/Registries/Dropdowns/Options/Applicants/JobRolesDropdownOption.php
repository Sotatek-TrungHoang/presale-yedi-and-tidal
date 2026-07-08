<?php

namespace App\Registries\Dropdowns\Options\Applicants;

use App\DTOs\Dropdowns\DropdownData;
use App\DTOs\Dropdowns\DropdownValue;
use App\Models\JobRole;
use App\Registries\Dropdowns\Options\AbstractDropdownOption;
use Illuminate\Support\Collection;

class JobRolesDropdownOption extends AbstractDropdownOption
{
    public function getId(): string
    {
        return 'job_roles';
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
        return JobRole::query()
            ->orderBy('name')
            ->get()
            ->map(function (JobRole $jobRole) {
                return new DropdownValue(label: $jobRole->name, value: $jobRole->id);
            });
    }
}

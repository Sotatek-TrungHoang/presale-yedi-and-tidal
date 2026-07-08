<?php

namespace App\Registries\Dropdowns\Options\Applicants;

use App\DTOs\Dropdowns\DropdownData;
use App\DTOs\Dropdowns\DropdownValue;
use App\Enums\ApplicantQualification;
use App\Registries\Dropdowns\Options\AbstractEnumDropdownOption;
use Illuminate\Support\Collection;

class QualificationsDropdownOption extends AbstractEnumDropdownOption
{
    public function getId(): string
    {
        return 'qualifications';
    }

    /**
     * @return Collection<array-key, DropdownValue>
     */
    public function getResults(DropdownData $dropdownData): Collection
    {
        return $this->getEnumResults($dropdownData, ApplicantQualification::class);
    }
}

<?php

namespace App\Registries\Dropdowns\Options\Common;

use App\DTOs\Dropdowns\DropdownData;
use App\DTOs\Dropdowns\DropdownValue;
use App\Registries\Dropdowns\Options\AbstractDropdownOption;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\Cache;
use League\ISO3166\ISO3166;

class CountriesDropdownOption extends AbstractDropdownOption
{
    public function getId(): string
    {
        return 'countries';
    }

    /**
     * @return Collection<array-key, DropdownValue>
     */
    public function getResults(DropdownData $dropdownData): Collection
    {

        $shouldCache = empty($dropdownData->search);
        $cacheKey = 'dropdown_countries';

        if ($shouldCache && Cache::has($cacheKey)) {
            return cache($cacheKey);
        }

        $countries = collect((new ISO3166)->all());

        $sortedCountries = $countries
            ->filter(fn ($country) => $dropdownData->search ? str_contains(strtolower($country['name']), strtolower($dropdownData->search)) : true)
            ->map(fn ($country) => new DropdownValue(label: $country['name'], value: $country['alpha2']))
            ->sortBy('label')
            ->values();

        $gbCountry = $sortedCountries->firstWhere('value', 'GB');
        if ($gbCountry) {
            $sortedCountries = $sortedCountries->reject(fn ($country) => $country->value === 'GB');
            $sortedCountries->prepend($gbCountry);
        }

        if ($shouldCache) {
            Cache::set($cacheKey, $sortedCountries);
        }

        return $sortedCountries;
    }
}

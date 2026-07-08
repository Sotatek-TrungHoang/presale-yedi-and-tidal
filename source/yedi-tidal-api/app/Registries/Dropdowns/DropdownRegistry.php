<?php

namespace App\Registries\Dropdowns;

use Illuminate\Support\Collection;

/**
 * @property Collection<string, DropdownOptionInterface> $options
 */
class DropdownRegistry
{
    private Collection $options;

    public function __construct(DropdownOptionInterface ...$options)
    {
        $this->options = collect($options)->keyBy(fn (DropdownOptionInterface $type) => $type->getId());
    }

    /**
     * @return Collection<string, DropdownOptionInterface>
     */
    public function all(): Collection
    {
        return $this->options;
    }

    /**
     * @return string[]
     */
    public function ids(): array
    {
        return $this->all()->map(fn (DropdownOptionInterface $quoteProduct) => $quoteProduct->getId())->toArray();
    }

    public function get(string $key): ?DropdownOptionInterface
    {
        return $this->options->get($key);
    }
}

<?php

namespace App\Casts\Data;

use Exception;
use Illuminate\Support\Collection;
use Spatie\LaravelData\Casts\Cast;
use Spatie\LaravelData\Support\Creation\CreationContext;
use Spatie\LaravelData\Support\DataProperty;

class EnumCollectionCast implements Cast
{
    public function __construct(
        private readonly string $enumClass,
        private readonly bool $nullable = false
    ) {}

    public function cast(DataProperty $property, mixed $value, array $properties, CreationContext $context): mixed
    {
        if ($value === null) {
            if (! $this->nullable) {
                throw new Exception('Invalid type');
            }

            return null;
        }

        if (is_array($value)) {
            $value = collect($value);
        }

        if (! $value instanceof Collection) {
            throw new Exception('Invalid type');
        }

        return $value->map(fn ($enum) => $this->enumClass::from($enum));
    }
}

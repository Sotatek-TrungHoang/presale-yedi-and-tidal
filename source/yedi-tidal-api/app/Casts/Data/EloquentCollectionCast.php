<?php

namespace App\Casts\Data;

use Exception;
use Illuminate\Support\Collection;
use ReflectionClass;
use Spatie\LaravelData\Casts\Cast;
use Spatie\LaravelData\Support\Creation\CreationContext;
use Spatie\LaravelData\Support\DataProperty;

class EloquentCollectionCast implements Cast
{
    public function __construct(
        private readonly string $eloquentClass,
    ) {}

    public function cast(DataProperty $property, mixed $value, array $properties, CreationContext $context): mixed
    {
        if ($value === null) {
            return collect();
        }

        if (! is_iterable($value)) {
            $value = collect($value);
        }

        if (is_array($value)) {
            $value = collect($value);
        }

        if (! $value instanceof Collection) {
            throw new Exception('Invalid type');
        }

        $r = new ReflectionClass($this->eloquentClass);

        return $value->map(function ($id) use ($r) {
            if (is_object($id)) {
                if ($id::class !== $r->getName()) {
                    throw new Exception('Invalid type');
                }

                return $id;
            }

            return $r->newInstanceWithoutConstructor()->find($id);
        });
    }
}

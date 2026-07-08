<?php

namespace App\Casts\Data;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Arr;
use Spatie\LaravelData\Casts\Cast;
use Spatie\LaravelData\Support\Creation\CreationContext;
use Spatie\LaravelData\Support\DataProperty;

class EloquentCast implements Cast
{
    public function cast(DataProperty $property, mixed $value, array $properties, CreationContext $context): ?Model
    {
        if ($value === null) {
            return null;
        }

        if ($value instanceof Model) {
            return $value;
        }

        if (! $eloquentClass = Arr::first(array_keys($property->type->getAcceptedTypes()))) {
            throw new \Exception('Invalid type');
        }

        /** @var mixed $eloquentClass */

        return $eloquentClass::find($value);
    }
}

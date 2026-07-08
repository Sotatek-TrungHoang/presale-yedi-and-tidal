<?php

namespace App\Registries\Dropdowns\Options;

use App\Enums\UserType;
use App\Models\User;
use App\Registries\Dropdowns\DropdownOptionInterface;
use Illuminate\Support\Collection;
use Illuminate\Validation\UnauthorizedException;

abstract class AbstractDropdownOption implements DropdownOptionInterface
{
    public function allowedTypes(): Collection
    {
        return collect(UserType::cases());
    }

    public function public(): bool
    {
        return false;
    }

    public function authCheck(): self
    {

        if ($this->public()) {
            return $this;
        }

        /** @var User $user|null */
        $user = auth('sanctum')->user();
        if (! $user) {
            throw new UnauthorizedException('You must be signed in to access this resource');
        }

        $typer = $user->type;

        if ($this->allowedTypes()->doesntContain($typer)) {
            throw new UnauthorizedException('You are not allowed to access this resource');
        }

        return $this;
    }
}

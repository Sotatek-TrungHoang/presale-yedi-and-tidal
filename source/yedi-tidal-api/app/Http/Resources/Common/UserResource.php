<?php

namespace App\Http\Resources\Common;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin User
 *
 * @property User $resource
 */
class UserResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {

        /** @var User|null $user */
        $user = $request->user();

        return [
            'id' => $this->id,
            'type' => $this->type->value,
            'title' => $this->title->value,
            'title_label' => $this->title->label(),
            'first_name' => $this->first_name,
            'last_name' => $this->last_name,
            'name' => $this->name,
            $this->mergeWhen($user?->isAdmin() || $user->is($this->resource), fn () => [
                'email' => $this->email,
                'telephone' => $this->telephone,
            ]),
            'date_of_birth' => $this->date_of_birth,
            'created_at' => $this->created_at,
        ];
    }
}

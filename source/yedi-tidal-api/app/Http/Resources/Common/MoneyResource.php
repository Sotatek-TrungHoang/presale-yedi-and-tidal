<?php

namespace App\Http\Resources\Common;

use Brick\Money\Money;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

/**
 * @mixin Money
 */
class MoneyResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        $locale = app()->getLocale();

        return [
            'display' => $this->formatTo($locale),
            'currency' => $this->getCurrency(),
            'amount' => $this->getAmount()->toFloat(),
            'minor_amount' => $this->getMinorAmount()->toInt(),
        ];
    }
}

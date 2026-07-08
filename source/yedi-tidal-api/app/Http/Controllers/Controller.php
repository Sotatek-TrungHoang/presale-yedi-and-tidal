<?php

namespace App\Http\Controllers;

use Illuminate\Http\JsonResponse;
use Spatie\LaravelData\Optional;

abstract class Controller
{
    protected function stdResponse(string|Optional|null $message = new Optional, mixed $data = null, int $status = JsonResponse::HTTP_OK): JsonResponse
    {
        $data = [
            'data' => $data,
        ];

        if (! $message instanceof Optional) {
            $data['message'] = $message;
        }

        return new JsonResponse(
            data: $data,
            status: $status
        );
    }

    protected function stdSuccess(mixed $data = null, string|Optional|null $message = new Optional, int $status = JsonResponse::HTTP_OK): JsonResponse
    {
        return $this->stdResponse(
            message: $message,
            data: $data,
            status: $status
        );
    }

    protected function stdError(string|Optional|null $message = new Optional, int $status = JsonResponse::HTTP_BAD_REQUEST, mixed $data = null): JsonResponse
    {
        return $this->stdResponse(
            message: $message,
            data: $data,
            status: $status
        );
    }
}

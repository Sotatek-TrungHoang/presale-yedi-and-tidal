<?php

namespace App\Http\Middleware;

use App\Models\DeviceToken;
use App\Models\User;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class DeviceTokenMiddleware
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {

        $token = $request->header('X-FCM-Token');
        if (! $token) {
            return $next($request);
        }

        /** @var User|null $user */
        $user = $request->user();
        if (! $user) {
            DeviceToken::query()->where('device_token', $token)->delete();

            return $next($request);
        }

        $tokenModel = DeviceToken::query()->updateOrCreate(['device_token' => $token], [
            'user_id' => $user->id,
            'last_used' => now(),
        ]);

        $request->merge(['fcm_device_token' => $tokenModel]);

        return $next($request);
    }
}

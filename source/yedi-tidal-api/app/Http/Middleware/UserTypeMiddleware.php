<?php

namespace App\Http\Middleware;

use App\Enums\UserType;
use App\Models\User;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;
use Symfony\Component\HttpKernel\Exception\HttpException;

class UserTypeMiddleware
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next, string $userType): Response
    {
        $userType = UserType::from($userType);

        /** @var User|null $user */
        $user = $request->user();
        if (! $user) {
            throw new HttpException(401, 'You must be logged in to access this route');
        }

        $type = $user->type;
        if (! $type) {
            throw new HttpException(401, 'You must be logged in to access this route');
        }

        if ($type === $userType) {
            return $next($request);
        }

        $message = match ($userType) {
            UserType::Admin => 'You must be an admin to access this route',
            UserType::Advertiser => ___('You must be an advertiser to access this route'),
            UserType::Applicant => ___('You must be an applicant to access this route'),
        };
        throw new HttpException(403, $message);
    }
}

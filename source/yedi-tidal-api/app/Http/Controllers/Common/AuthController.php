<?php

namespace App\Http\Controllers\Common;

use App\Http\Controllers\Controller;
use App\Http\Requests\Common\Auth\ForgotPasswordRequest;
use App\Http\Requests\Common\Auth\LoginRequest;
use App\Http\Requests\Common\Auth\ResetPasswordRequest;
use App\Http\Resources\Common\AuthUserResource;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Password;

class AuthController extends Controller
{
    public function __construct() {}

    public function login(LoginRequest $request)
    {

        $data = $request->validated();
        $email = $data['email'];
        $password = $data['password'];

        /** @var User|null $user */
        $user = User::query()->where('email', $email)->first();
        if (! $user) {
            return $this->stdError(__('auth.failed'), JsonResponse::HTTP_UNAUTHORIZED);
        }

        if (! Hash::check($password, $user->password)) {
            return $this->stdError(__('auth.failed'), JsonResponse::HTTP_UNAUTHORIZED);
        }

        $token = $user->createToken('sign_up')->plainTextToken;

        return $this->stdSuccess([
            'token' => $token,
            'user' => new AuthUserResource($user),
        ]);
    }

    public function user()
    {
        return new AuthUserResource(Auth::user());
    }

    public function forgotPassword(ForgotPasswordRequest $request)
    {

        $data = $request->validated();
        $email = $data['email'];

        Password::sendResetLink(['email' => $email]);

        return $this->stdSuccess();
    }

    public function resetPassword(ResetPasswordRequest $request)
    {

        $data = $request->validated();
        $email = $data['email'];
        $token = $data['token'];
        $password = $data['password'];

        $status = Password::reset(
            ['email' => $email, 'token' => $token, 'password' => $password],
            function (User $user, string $password) {
                $user->forceFill([
                    'password' => Hash::make($password),
                ]);
                $user->save();
                if (! $user->hasVerifiedEmail()) {
                    $user->markEmailAsVerified();
                }
            }
        );

        if ($status !== Password::PASSWORD_RESET) {
            return $this->stdError(message: __($status));
        }

        return $this->stdSuccess();
    }
}

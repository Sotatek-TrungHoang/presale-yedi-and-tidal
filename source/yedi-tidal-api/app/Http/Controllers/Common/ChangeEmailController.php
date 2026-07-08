<?php

namespace App\Http\Controllers\Common;

use App\Http\Controllers\Controller;
use App\Http\Requests\Common\ChangeEmail\RequestEmailChangeRequest;
use App\Http\Requests\Common\ChangeEmail\VerifyEmailChangeCodeRequest;
use App\Http\Resources\Common\AuthUserResource;
use App\Models\User;
use App\Notifications\Common\VerifyNewEmailNotification;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Notification;
use Illuminate\Support\Str;

class ChangeEmailController extends Controller
{
    public function requestEmailChange(RequestEmailChangeRequest $request)
    {
        /** @var User $user */
        $user = Auth::user();
        $validData = $request->validated();
        $code = Str::padLeft('0', 6, strval(rand(0, 999999)));

        $user->update([
            'new_email' => $validData['new_email'],
            'new_email_code' => $code,
            'new_email_code_expires_at' => now()->addMinutes(10),
        ]);

        Notification::route('mail', $validData['new_email'])->notifyNow(new VerifyNewEmailNotification($user));

        return $this->stdSuccess();
    }

    public function verifyCode(VerifyEmailChangeCodeRequest $request)
    {
        /** @var User $user */
        $user = Auth::user();
        $validData = $request->validated();

        if ($user->new_email !== $validData['new_email']) {
            return $this->stdError('Invalid email given', data: ['action' => 'email']);
        }

        if ($user->new_email_code !== $validData['code']) {
            return $this->stdError('Invalid code given', data: ['action' => 'code']);
        }

        if ($user->new_email_code_expires_at->isPast()) {
            return $this->stdError('Code has expired', data: ['action' => 'email']);
        }

        if (User::query()->where('email', $user->new_email)->exists()) {
            return $this->stdError('This email is already in use', data: ['action' => 'email']);
        }

        $user->update([
            'email' => $user->new_email,
            'new_email' => null,
            'new_email_code' => null,
            'new_email_code_expires_at' => null,
        ]);

        return new AuthUserResource($user);
    }
}

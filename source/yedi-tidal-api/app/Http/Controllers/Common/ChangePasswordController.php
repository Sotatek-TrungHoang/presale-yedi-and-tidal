<?php

namespace App\Http\Controllers\Common;

use App\Http\Controllers\Controller;
use App\Http\Requests\Common\ChangePassword\ChangePasswordRequest;
use App\Models\User;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;

class ChangePasswordController extends Controller
{
    public function __invoke(ChangePasswordRequest $request)
    {
        /** @var User $user */
        $user = Auth::user();
        $validData = $request->validated();

        $user->update([
            'password' => Hash::make($validData['password']),
        ]);

        return $this->stdSuccess();
    }
}

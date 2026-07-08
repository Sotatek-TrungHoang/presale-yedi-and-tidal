<?php

use App\Http\Controllers\Common\AuthController;
use App\Http\Controllers\Common\ChangeEmailController;
use App\Http\Controllers\Common\ChangePasswordController;
use App\Http\Controllers\Common\DeleteAccountController;
use App\Http\Controllers\Common\DropdownController;
use App\Http\Controllers\Common\ImageConversionController;
use App\Http\Controllers\Common\SettingsController;
use App\Http\Controllers\Common\UploadController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/', function (Request $request) {
    return 'Common';
});

Route::group(['controller' => AuthController::class, 'prefix' => 'auth/', 'as' => 'auth.'], function () {
    Route::post('login', 'login')->name('login');
    Route::post('forgot-password', 'forgotPassword')->name('forgot-password');
    Route::post('reset-password', 'resetPassword')->name('reset-password');
});

Route::middleware('auth:sanctum')->group(function () {
    Route::get('auth/user', [AuthController::class, 'user'])->name('auth.user');
    Route::post('uploads', [UploadController::class, 'store']);
    Route::post('uploads/from-google', [UploadController::class, 'storeFromGoogle']);

    Route::post('change-email/request', [ChangeEmailController::class, 'requestEmailChange'])->name('change-email.request');
    Route::post('change-email/verify-code', [ChangeEmailController::class, 'verifyCode'])->name('change-email.verify');
    Route::post('change-password', ChangePasswordController::class)->name('change-password');

    Route::post('delete-account', DeleteAccountController::class)->name('delete-account');
});

Route::post('dropdowns', DropdownController::class)->name('dropdowns');
Route::get('uploads/{upload}', [UploadController::class, 'serve'])->name('uploads.serve');
Route::get('image-conversions/{imageConversion}', [ImageConversionController::class, 'serve'])->name('image-conversions.serve');
Route::get('settings', SettingsController::class)->name('settings');

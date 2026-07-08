<?php

use App\Http\Controllers\Advertiser\AdvertApplicationsController;
use App\Http\Controllers\Advertiser\AdvertiserProfileController;
use App\Http\Controllers\Advertiser\AdvertiserSignUpController;
use App\Http\Controllers\Advertiser\AdvertsController;
use App\Http\Controllers\Advertiser\ApplicationsController;
use App\Http\Controllers\Advertiser\ContractsController;
use App\Http\Controllers\Advertiser\HeartedApplicantsController;
use App\Http\Controllers\Advertiser\InvoicesController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/', function (Request $request) {
    return 'Advertiser';
});

Route::controller(AdvertiserSignUpController::class)
    ->prefix('sign-up')
    ->as('sign-up.')
    ->group(function () {
        Route::get('pages', 'pages')->withoutMiddleware(['auth:sanctum', 'user-type:advertiser']);
        Route::post('create-profile', 'createProfile')->withoutMiddleware(['auth:sanctum', 'user-type:advertiser']);
        Route::post('submit-address', 'submitAddress');
        Route::post('submit-photograph', 'submitPhotograph');
        Route::post('complete-sign-up', 'completeSignUp');
        Route::post('cancel-sign-up', 'cancelSignUp');
    });

Route::controller(AdvertiserProfileController::class)
    ->prefix('profile')
    ->as('profile.')
    ->group(function () {
        Route::post('update-profile', 'updateProfile');
        Route::post('update-address', 'updateAddress');
    });

Route::controller(AdvertsController::class)
    ->prefix('adverts')
    ->as('adverts.')
    ->group(function () {
        Route::get('/', 'index');
        Route::post('/', 'store');
        Route::get('{advert}', 'show');
        Route::delete('{advert}', 'destroy');
        Route::get('{advert}/applications', [AdvertApplicationsController::class, 'index']);
    });

Route::controller(ApplicationsController::class)
    ->prefix('applications')
    ->as('applications.')
    ->group(function () {
        Route::get('/', 'index');
    });

Route::post('applications/{application}/accept', [AdvertApplicationsController::class, 'accept']);
Route::post('applications/{application}/decline', [AdvertApplicationsController::class, 'decline']);
Route::post('applications/{application}/rate', [AdvertApplicationsController::class, 'rate']);

Route::get('applicants', [HeartedApplicantsController::class, 'index']);
Route::post('applicants/{applicant}/heart', [HeartedApplicantsController::class, 'heart']);
Route::post('applicants/{applicant}/unheart', [HeartedApplicantsController::class, 'unheart']);

Route::apiResource('invoices', InvoicesController::class)->only(['index']);
Route::apiResource('contracts', ContractsController::class)->only(['index']);

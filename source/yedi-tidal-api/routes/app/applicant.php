<?php

use App\Http\Controllers\Applicant\AdvertsController;
use App\Http\Controllers\Applicant\ApplicantProfileController;
use App\Http\Controllers\Applicant\ApplicantSignUpController;
use App\Http\Controllers\Applicant\BookingsController;
use App\Http\Controllers\Applicant\ContractsController;
use App\Http\Controllers\Applicant\DeclarationController;
use App\Http\Controllers\Applicant\PayslipsController;
use App\Http\Controllers\Applicant\ReferenceController;
use App\Http\Controllers\Applicant\RequiredEvidenceController;
use App\Http\Controllers\Applicant\VideoVerificationController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

Route::get('/', function (Request $request) {
    return 'Applicant';
});

Route::controller(ApplicantSignUpController::class)
    ->prefix('sign-up')
    ->as('sign-up.')
    ->group(function () {
        Route::get('pages', 'pages')->withoutMiddleware(['auth:sanctum', 'user-type:applicant']);
        Route::post('create-profile', 'createProfile')->withoutMiddleware(['auth:sanctum', 'user-type:applicant']);
        Route::post('submit-compliance', 'submitCompliance');
        Route::post('submit-address', 'submitAddress');
        Route::post('submit-qualifications', 'submitQualifications');
        Route::post('submit-references', 'submitReferences');
        Route::post('submit-evidence/{requiredEvidence}', 'submitEvidence');
        Route::post('agree-to-declaration/{declaration}', 'agreeToDeclaration');
        Route::post('submit-right-to-work-declaration', 'submitRightToWorkDeclaration');
        Route::post('complete-sign-up', 'completeSignUp');
        Route::post('cancel-sign-up', 'cancelSignUp');
    });

Route::apiResource('required-evidence', RequiredEvidenceController::class)->only(['show']);
Route::apiResource('declarations', DeclarationController::class)->only(['show']);
Route::apiResource('references', ReferenceController::class)->only(['index']);

Route::controller(ApplicantProfileController::class)
    ->prefix('profile')
    ->as('profile.')
    ->group(function () {
        Route::get('/', 'index');
        Route::post('update-profile', 'updateProfile');
        Route::post('update-compliance', 'updateCompliance');
        Route::post('update-address', 'updateAddress');
        Route::post('update-qualifications', 'updateQualifications');
        Route::post('update-evidence/{requiredEvidence}', 'updateEvidence');
        Route::post('agree-to-declaration/{declaration}', 'agreeToDeclaration');
        Route::post('update-right-to-work-declaration', 'updateRightToWorkDeclaration');
    });

Route::controller(AdvertsController::class)
    ->prefix('adverts')
    ->as('adverts.')
    ->group(function () {
        Route::get('/', 'index');
        Route::get('{advert}', 'show');
        Route::post('{advert}/apply', 'apply');
        Route::post('{advert}/cancel-application', 'cancelApplication');
    });

Route::controller(BookingsController::class)
    ->prefix('bookings')
    ->as('bookings.')
    ->group(function () {
        Route::get('confirmed', 'confirmed');
        Route::get('applied-to', 'appliedTo');
    });

Route::controller(VideoVerificationController::class)
    ->prefix('video-verifications')
    ->as('video-verifications.')
    ->group(function () {
        Route::post('/', 'store');
        Route::post('{videoVerification}/submit', 'submit');
    });

Route::apiResource('payslips', PayslipsController::class)->only(['index']);
Route::apiResource('contracts', ContractsController::class)->only(['index']);

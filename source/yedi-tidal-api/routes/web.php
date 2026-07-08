<?php

use App\Http\Controllers\Public\ReferenceController;
use Illuminate\Support\Facades\Route;

Route::group([
    'controller' => ReferenceController::class,
    'as' => 'reference.',
    'prefix' => '/reference/{reference:reference_id}',
    'middleware' => ['signed'],
], function () {
    Route::get('/', 'index')->name('show');
    Route::post('/', 'store')->name('store');
});

Route::get('/', function () {

    if (config('app.configuration') === 'yedi') {
        return view('landing-yedi');
    }
    if (config('app.configuration') === 'tidal') {
        return view('landing-tidal');
    }

    return null;
});

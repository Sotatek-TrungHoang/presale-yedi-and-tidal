<?php

use App\Console\Commands\Adverts\MarkAdvertsAsCompleteCommand;
use App\Console\Commands\Adverts\UpdateApprovedAdvertsStatusesCommand;
use App\Console\Commands\Adverts\UpdatePendingAllocationAdvertsStatusesCommand;
use App\Console\Commands\Common\ClearExpiredAddressesCommand;
use App\Console\Commands\Common\ClearExpiredDeviceTokensCommand;
use App\Console\Commands\Common\ClearExpiredUploadsCommand;
use App\Enums\UserType;
use App\Http\Middleware\DeviceTokenMiddleware;
use App\Http\Middleware\UserTypeMiddleware;
use Illuminate\Console\Scheduling\Schedule;
use Illuminate\Foundation\Application;
use Illuminate\Foundation\Configuration\Exceptions;
use Illuminate\Foundation\Configuration\Middleware;
use Sentry\Laravel\Integration;

return Application::configure(basePath: dirname(__DIR__))
    ->withRouting(
        web: __DIR__.'/../routes/web.php',
        // api: __DIR__.'/../routes/api.php',
        commands: __DIR__.'/../routes/console.php',
        health: '/up',
        then: function () {

            if (app()->environment('local')) {
                Route::get('/testing', function () {
                    return 'This is for testing purposes only';
                });
            }

            Route::middleware(['api'])
                ->prefix('app/common')
                ->as('common.')
                ->group(base_path('routes/app/common.php'));

            Route::middleware(['api', 'auth:sanctum', 'user-type:'.UserType::Applicant->value])
                ->prefix('app/applicant')
                ->as('applicant.')
                ->group(base_path('routes/app/applicant.php'));

            Route::middleware(['api', 'auth:sanctum', 'user-type:'.UserType::Advertiser->value])
                ->prefix('app/advertiser')
                ->as('advertiser.')
                ->group(base_path('routes/app/advertiser.php'));
        }

    )
    ->withMiddleware(function (Middleware $middleware) {
        $middleware->alias([
            'user-type' => UserTypeMiddleware::class,
        ]);
        $middleware->appendToGroup('api', DeviceTokenMiddleware::class);
    })
    ->withExceptions(function (Exceptions $exceptions) {
        Integration::handles($exceptions);
    })
    ->withSchedule(function (Schedule $schedule) {
        // Common
        $schedule->command(ClearExpiredAddressesCommand::class)->everyFiveMinutes();
        $schedule->command(ClearExpiredDeviceTokensCommand::class)->everyFiveMinutes();
        $schedule->command(ClearExpiredUploadsCommand::class)->everyFiveMinutes();

        // Adverts
        $schedule->command(MarkAdvertsAsCompleteCommand::class)->everyMinute();
        $schedule->command(UpdateApprovedAdvertsStatusesCommand::class)->everyMinute();
        $schedule->command(UpdatePendingAllocationAdvertsStatusesCommand::class)->everyMinute();
    })
    ->create();

<?php

namespace App\Providers;

use App\Models\User;
use App\Registries\Dropdowns\DropdownOptionInterface;
use App\Registries\Dropdowns\DropdownRegistry;
use App\Services\DeepLinkUrlService;
use App\Services\UrlService;
use Illuminate\Auth\Notifications\ResetPassword;
use Illuminate\Foundation\Application;
use Illuminate\Support\Facades\App;
use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Str;
use RecursiveDirectoryIterator;
use RecursiveIteratorIterator;
use ReflectionClass;
use ReflectionException;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        $this->tags();
        App::singleton(UrlService::class, fn () => new UrlService(baseUrl: config('app.url')));
        App::singleton(DeepLinkUrlService::class, fn () => new DeepLinkUrlService(baseUrl: config('app.deeplink_url')));
        App::singleton(DropdownRegistry::class, fn (Application $app) => new DropdownRegistry(...$app->tagged('dropdown-options')));
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        //
        \Filament\Forms\Components\DatePicker::configureUsing(function ($datepicker) {
            $datepicker->native(false);
        });
        \Filament\Forms\Components\DateTimePicker::configureUsing(function ($datetimepicker) {
            $datetimepicker->native(false);
        });
        \Filament\Forms\Components\Select::configureUsing(function ($select) {
            $select->native(false);
        });

        ResetPassword::createUrlUsing(function (User $user, string $token, array $additional = []) {

            /** @var DeepLinkUrlService */
            $frontendUrlService = app()->get(DeepLinkUrlService::class);

            return $frontendUrlService->resetPassword($user->email, $token, $additional);
        });
    }

    private function tags()
    {
        $this->dropdownTags();
    }

    private function dropdownTags()
    {

        $optionDir = base_path('app/Registries/Dropdowns/Options/');

        $rii = new RecursiveIteratorIterator(new RecursiveDirectoryIterator($optionDir));
        $files = collect();

        /** @var SplFileInfo $file */
        foreach ($rii as $file) {
            if ($file->isDir()) {
                continue;
            }

            $files->push($file->getPathname());
        }

        $optionClasses = $files->map(function (string $path) use ($optionDir) {

            $className = Str::of($path)
                ->replace($optionDir, 'App\\Registries\\Dropdowns\\Options\\')
                ->replace(DIRECTORY_SEPARATOR, '\\')
                ->replace('.php', '')
                ->toString();

            try {
                $reflectionClass = new ReflectionClass($className);
            } catch (ReflectionException $e) {
                return false;
            }

            if ($reflectionClass->isAbstract()) {
                return false;
            }

            if (! $reflectionClass->implementsInterface(DropdownOptionInterface::class)) {
                return false;
            }

            return $className;
        })
            ->filter()
            ->values()
            ->toArray();

        $this->app->tag($optionClasses, 'dropdown-options');
    }
}

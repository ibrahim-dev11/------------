<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;
use Kreait\Firebase\Factory;
use App\Services\FirebaseNotificationService;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        // Register Firebase
        $this->registerFirebase();

        // Register Firebase Notification Service
        $this->app->singleton(FirebaseNotificationService::class, function ($app) {
            return new FirebaseNotificationService($app['firebase.messaging']);
        });
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        //
    }

    /**
     * Register Firebase instance.
     */
    protected function registerFirebase(): void
    {
        $this->app->singleton('firebase', function ($app) {
            $credentialsPath = config('firebase.credentials');

            if (!$credentialsPath || !file_exists($credentialsPath)) {
                \Illuminate\Support\Facades\Log::warning(
                    "Firebase credentials file not found at: {$credentialsPath}. Firebase features are disabled."
                );
                return null;
            }

            return (new Factory())->withServiceAccount($credentialsPath);
        });

        $this->app->singleton('firebase.messaging', function ($app) {
            $firebase = $app['firebase'];
            return $firebase ? $firebase->createMessaging() : null;
        });
    }
}

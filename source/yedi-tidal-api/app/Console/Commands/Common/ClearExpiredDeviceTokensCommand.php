<?php

namespace App\Console\Commands\Common;

use App\Models\DeviceToken;
use Illuminate\Console\Command;

class ClearExpiredDeviceTokensCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'common:device-tokens:clear-expired';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Clear old device tokens';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        DeviceToken::query()->where('last_used', '<', now()->subWeek())->delete();
    }
}

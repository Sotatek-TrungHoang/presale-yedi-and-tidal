<?php

namespace App\Console\Commands\Common;

use App\Models\Address;
use Illuminate\Console\Command;

class ClearExpiredAddressesCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'common:addresses:clear-expired';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Clear unowned addresses';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        Address::query()
            ->where('expires_at', '<', now())
            ->whereNull('owner_id')
            ->forceDelete();
    }
}

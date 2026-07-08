<?php

namespace App\Console\Commands\Contracts;

use App\Jobs\CreateAdvertiserContractJob;
use App\Models\Advertiser;
use Illuminate\Console\Command;

class GenerateAdvertiserContractsCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'contracts:generate-advertiser';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Generate contracts for advertisers';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        Advertiser::query()
            ->cursor()
            ->each(fn (Advertiser $advertiser) => CreateAdvertiserContractJob::dispatchSync($advertiser));
    }
}

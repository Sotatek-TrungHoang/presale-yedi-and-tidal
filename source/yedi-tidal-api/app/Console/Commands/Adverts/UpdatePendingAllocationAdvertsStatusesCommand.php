<?php

namespace App\Console\Commands\Adverts;

use App\Enums\AdvertStatus;
use App\Models\Advert;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Log;

class UpdatePendingAllocationAdvertsStatusesCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'adverts:pending-allocation-statuses';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Update pending allocation adverts statuses';

    /**
     * Execute the console command.
     */
    public function handle()
    {
        Advert::query()
            ->where('status', AdvertStatus::PendingAllocation)
            ->where('starts_at', '<', now())
            ->cursor()
            ->each(function (Advert $advert) {
                Log::channel('adverts')->info('Marking advert as not filled from pending: '.$advert->id);
                $this->info('Marking advert as not filled from pending: '.$advert->id);
                $advert->update(['status' => AdvertStatus::NotFilled]);
            });
    }
}

<?php

namespace App\Console\Commands\Adverts;

use App\Enums\AdvertStatus;
use App\Jobs\CreateAdvertInvoiceJob;
use App\Jobs\CreateAdvertPayslipJob;
use App\Models\Advert;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Log;

class MarkAdvertsAsCompleteCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'adverts:mark-as-complete';

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
            ->whereNull('marked_as_completed_at')
            ->where('ends_at', '<', now())
            ->cursor()
            ->each(function (Advert $advert) {

                $this->info('Marking advert as completed: '.$advert->id);
                Log::channel('adverts')->info('Marking advert as completed: '.$advert->id);

                $advert->update(['marked_as_completed_at' => now()]);
                if ($advert->status === AdvertStatus::Filled) {
                    CreateAdvertInvoiceJob::dispatch($advert);
                    CreateAdvertPayslipJob::dispatch($advert);
                }
            });
    }
}

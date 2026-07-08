<?php

namespace App\Console\Commands\Adverts;

use App\Enums\AdvertStatus;
use App\Enums\ApplicationStatus;
use App\Handlers\Notifications\NotifyAdvertiserHandler;
use App\Models\Advert;
use App\Notifications\Advertiser\AdvertHadNoApplicationsNotification;
use App\Notifications\Advertiser\AdvertPendingAllocationNotification;
use Illuminate\Console\Command;
use Illuminate\Support\Facades\Log;

class UpdateApprovedAdvertsStatusesCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'adverts:approved-statuses';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Update approved adverts statuses';

    /**
     * Execute the console command.
     */
    public function handle(NotifyAdvertiserHandler $notifyAdvertiserHandler)
    {
        Advert::query()
            ->where('status', AdvertStatus::Approved)
            ->where('apply_by', '<', now())
            ->cursor()
            ->each(function (Advert $advert) use ($notifyAdvertiserHandler) {
                if ($advert->applications()->where('status', ApplicationStatus::Pending)->exists()) {

                    Log::channel('adverts')->info('Marking advert as pending from approved: '.$advert->id);

                    $advert->update(['status' => AdvertStatus::PendingAllocation]);
                    $notifyAdvertiserHandler->handle($advert->advertiser, new AdvertPendingAllocationNotification($advert));
                } else {

                    Log::channel('adverts')->info('Marking advert as not filled from approved: '.$advert->id);

                    $advert->update(['status' => AdvertStatus::NotFilled]);
                    $notifyAdvertiserHandler->handle($advert->advertiser, new AdvertHadNoApplicationsNotification($advert));
                }
            });
    }
}

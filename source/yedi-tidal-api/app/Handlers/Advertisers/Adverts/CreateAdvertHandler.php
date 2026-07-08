<?php

namespace App\Handlers\Advertisers\Adverts;

use App\DTOs\Adverts\CreateAdvertData;
use App\Enums\AdvertStatus;
use App\Handlers\Advertisers\Documents\CreateDocumentHandler;
use App\Handlers\Notifications\NotifyAdminsHandler;
use App\Handlers\Settings\SettingsResolver;
use App\Models\Advert;
use App\Models\Advertiser;
use App\Models\Shift;
use App\Notifications\Admin\NewAdvertCreatedNotification;
use Illuminate\Support\Facades\DB;

class CreateAdvertHandler
{
    public function __construct(
        protected CreateDocumentHandler $createDocumentHandler,
        protected NotifyAdminsHandler $notifyAdminsHandler,
        protected SettingsResolver $settingsResolver,
    ) {}

    public function handle(CreateAdvertData $data, Advertiser $advertiser)
    {
        $settings = $this->settingsResolver->resolve();

        try {
            $shifts = collect();
            $pointer = $data->starts_at->clone();
            do {
                $shiftStartsAt = $pointer->clone()->setTimeFromTimeString($data->shift_start_time);
                $shiftEndsAt = $pointer->clone()->setTimeFromTimeString($data->shift_end_time);
                if ($shiftStartsAt > $shiftEndsAt) {
                    $shiftEndsAt = $shiftEndsAt->addDay();
                }

                $shifts->push(new Shift([
                    'starts_at' => $shiftStartsAt,
                    'ends_at' => $shiftEndsAt,
                ]));

                $pointer = $pointer->addDay();
            } while ($pointer->format('Y-m-d') <= $data->ends_at->format('Y-m-d'));

            $advertStartsAt = $shifts->first()['starts_at'];
            $advertEndsAt = $shifts->last()['ends_at'];

            DB::beginTransaction();
            $advert = new Advert([
                ...$data->toArray(),
                'starts_at' => $advertStartsAt,
                'ends_at' => $advertEndsAt,
                'apply_by' => $data->apply_by ?? now(),
                'status' => AdvertStatus::PendingApproval,
                'applicant_charge_percentage' => $settings->default_applicant_charge_percentage,
                'advertiser_charge_percentage' => $settings->default_advertiser_charge_percentage,
            ]);
            $advert->advertiser()->associate($advertiser);
            $advert->address()->associate($advertiser->address);
            $advert->save();

            $advert->shifts()->saveMany($shifts);

            foreach ($data->documents as $documentData) {
                $this->createDocumentHandler->handle($documentData, $advert);
            }

            DB::commit();
        } catch (\Throwable $th) {
            DB::rollBack();
            throw $th;
        }

        $this->notifyAdminsHandler->handle(new NewAdvertCreatedNotification($advert));

        return $advert;
    }
}

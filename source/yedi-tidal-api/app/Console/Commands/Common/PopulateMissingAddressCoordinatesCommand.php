<?php

namespace App\Console\Commands\Common;

use App\Handlers\Addresses\GetAddressCoordinatesHandler;
use App\Models\Address;
use Illuminate\Console\Command;

class PopulateMissingAddressCoordinatesCommand extends Command
{
    /**
     * The name and signature of the console command.
     *
     * @var string
     */
    protected $signature = 'common:addresses:populate-coordinates';

    /**
     * The console command description.
     *
     * @var string
     */
    protected $description = 'Populate missing address coordinates';

    /**
     * Execute the console command.
     */
    public function handle(GetAddressCoordinatesHandler $getAddressCoordinatesHandler)
    {
        Address::query()
            ->where(fn ($query) => $query->whereNull('latitude')->orWhereNull('longitude'))
            ->cursor()
            ->each(function (Address $address) use ($getAddressCoordinatesHandler) {
                $result = $getAddressCoordinatesHandler->handle($address);
                if ($result) {
                    $address->latitude = $result['latitude'];
                    $address->longitude = $result['longitude'];
                    $address->saveQuietly();
                }
            });
    }
}

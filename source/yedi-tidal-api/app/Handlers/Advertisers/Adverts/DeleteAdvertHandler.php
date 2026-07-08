<?php

namespace App\Handlers\Advertisers\Adverts;

use App\Models\Advert;
use Illuminate\Support\Facades\DB;

class DeleteAdvertHandler
{
    public function handle(Advert $advert)
    {

        try {
            DB::beginTransaction();
            foreach ($advert->documents as $document) {
                $document->upload()->delete();
                $document->delete();
            }

            $advert->delete();
            DB::commit();
        } catch (\Throwable $th) {
            DB::rollBack();
            throw $th;
        }

        return $advert;
    }
}

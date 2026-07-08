<?php

namespace App\Http\Controllers\Advertiser;

use App\Http\Controllers\Controller;
use App\Http\Controllers\Traits\AdvertiserPortalTrait;
use App\Http\Requests\Advertiser\Profile\UpdateProfileRequest;
use App\Http\Requests\Common\Profile\UpdateAddressRequest;
use App\Models\Address;
use App\Models\Upload;
use Illuminate\Support\Facades\DB;

class AdvertiserProfileController extends Controller
{
    use AdvertiserPortalTrait;

    public function __construct()
    {
        //
    }

    public function updateProfile(UpdateProfileRequest $request)
    {
        $validData = $request->validated();
        $advertiser = $this->getAdvertiser();

        try {
            DB::beginTransaction();

            $photograph = Upload::query()->findOrFail($validData['photograph_id']);
            $advertiser->fill($validData);
            $advertiser->photograph()->associate($photograph);
            $advertiser->save();
            $photograph->owner()->associate($advertiser)->save();

            DB::commit();
        } catch (\Throwable $th) {
            DB::rollBack();
            throw $th;
        }

        return $this->stdSuccess(message: 'Profile updated successfully');
    }

    public function updateAddress(UpdateAddressRequest $request)
    {
        $validData = $request->validated();
        $advertiser = $this->getAdvertiser();

        $existingAddress = $advertiser->address;
        $address = new Address($validData);
        $address->owner()->associate($advertiser);

        if (! $existingAddress || ! $existingAddress->isSameAs($address)) {
            try {
                DB::beginTransaction();
                $address->save();
                $advertiser->address()->associate($address)->save();
                DB::commit();
            } catch (\Throwable $th) {
                DB::rollBack();
                throw $th;
            }
        }

        return $this->stdSuccess(message: 'Address updated successfully');
    }
}

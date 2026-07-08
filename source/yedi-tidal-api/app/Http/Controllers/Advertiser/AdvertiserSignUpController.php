<?php

namespace App\Http\Controllers\Advertiser;

use App\Enums\AdvertiserComplianceStatus;
use App\Enums\ProfileStatus;
use App\Enums\UserType;
use App\Handlers\Advertisers\SignUp\AdvertiserSignUpPagesHandler;
use App\Handlers\Notifications\NotifyAdminsHandler;
use App\Http\Controllers\Controller;
use App\Http\Controllers\Traits\AdvertiserPortalTrait;
use App\Http\Requests\Advertiser\SignUp\CreateProfileRequest;
use App\Http\Requests\Advertiser\SignUp\SubmitAddressRequest;
use App\Http\Requests\Advertiser\SignUp\SubmitPhotographRequest;
use App\Http\Resources\Common\AuthUserResource;
use App\Jobs\CreateAdvertiserContractJob;
use App\Models\Address;
use App\Models\Advertiser;
use App\Models\Upload;
use App\Models\User;
use App\Notifications\Admin\AdvertiserSignUpCompleteNotification;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class AdvertiserSignUpController extends Controller
{
    use AdvertiserPortalTrait;

    public function __construct(
        protected AdvertiserSignUpPagesHandler $advertiserSignUpPagesHandler,
        protected NotifyAdminsHandler $notifyAdminsHandler,
    ) {
        //
    }

    public function pages()
    {
        /** @var User|null $user */
        $user = auth('sanctum')->user();

        $pages = $this->advertiserSignUpPagesHandler->handle($user);

        $currentPageIndex = collect($pages)->search(function ($page) {
            return $page['complete'] === false;
        });

        if ($currentPageIndex === null || $currentPageIndex === false) {
            $currentPageIndex = count($pages) - 1;
        }

        return response()->json([
            'pages' => $pages,
            'current_page_index' => $currentPageIndex,
        ]);
    }

    public function createProfile(CreateProfileRequest $request)
    {

        $validData = $request->validated();

        /** @var User|null $user */
        $user = auth('sanctum')->user();
        $existingUser = $user !== null;

        try {
            DB::beginTransaction();

            $advertiser = $user?->userable ?? new Advertiser([
                'compliance_status' => AdvertiserComplianceStatus::Pending,
                'profile_status' => ProfileStatus::Incomplete,
            ]);
            $advertiser->fill($validData['advertiser']);
            $advertiser->save();

            if (! $user) {
                $user = new User([
                    ...$validData,
                    'type' => UserType::Advertiser,
                    'password' => Hash::make($validData['password']),
                ]);
            } else {
                $user->fill($validData);
            }

            $user->userable()->associate($advertiser);
            $user->save();

            $token = $existingUser ? null : $user->createToken('sign_up')->plainTextToken;

            DB::commit();
        } catch (\Throwable $th) {
            DB::rollBack();
            throw $th;
        }

        return response()->json([
            'token' => $token,
            'user' => new AuthUserResource($user),
        ]);
    }

    public function submitAddress(SubmitAddressRequest $request)
    {

        $advertiser = $this->getAdvertiser();
        $validData = $request->validated();

        try {
            DB::beginTransaction();

            $address = new Address($validData);
            $address->owner()->associate($advertiser);
            $address->save();

            $advertiser->address()->associate($address)->save();

            DB::commit();
        } catch (\Throwable $th) {
            DB::rollBack();
            throw $th;
        }

        return new AuthUserResource(Auth::user());
    }

    public function submitPhotograph(SubmitPhotographRequest $request)
    {
        $advertiser = $this->getAdvertiser();
        $validData = $request->validated();

        $photograph = Upload::query()->findOrFail($validData['photograph_id']);

        try {
            DB::beginTransaction();

            $advertiser->photograph()->associate($photograph);
            $advertiser->save();

            $photograph->owner()->associate($advertiser)->save();

            DB::commit();
        } catch (\Throwable $th) {
            DB::rollBack();
            throw $th;
        }

        return new AuthUserResource(Auth::user());
    }

    public function completeSignUp()
    {

        $user = Auth::user();
        $pages = $this->advertiserSignUpPagesHandler->handle($user);

        $canCompleteSignUp = collect($pages)->every(function ($page) {
            return $page['complete'] === true || $page['code'] === 'sign_up_complete';
        });

        if (! $canCompleteSignUp) {
            return response()->json([
                'message' => 'Please complete all the required sign up steps',
            ], 400);
        }

        $advertiser = $this->getAdvertiser();
        $advertiser->update([
            'compliance_status' => AdvertiserComplianceStatus::Pending,
            'profile_status' => ProfileStatus::Pending,
            'sign_up_completed_at' => now(),
        ]);

        $this->notifyAdminsHandler->handle(new AdvertiserSignUpCompleteNotification($advertiser));
        CreateAdvertiserContractJob::dispatch($advertiser->fresh());

        return new AuthUserResource(Auth::user());
    }

    public function cancelSignUp()
    {

        $user = Auth::user();
        $advertiser = $this->getAdvertiser();

        if ($advertiser->sign_up_completed_at !== null) {
            return response()->json([
                'message' => 'You cannot cancel sign up after completing the process',
            ], 400);
        }

        try {
            DB::beginTransaction();
            $advertiser->photograph()->delete();
            $advertiser->addresses()->delete();
            $advertiser->uploads()->delete();
            $advertiser->contracts()->delete();
            $advertiser->heartedApplicants()->delete();
            $advertiser->adverts()->delete();
            $advertiser->delete();
            $user->update(['email' => sprintf('%s_deleted_%s', $user->email, now()->timestamp)]);
            $user->deviceTokens()->delete();
            $user->delete();
            DB::commit();
        } catch (\Throwable $th) {
            DB::rollBack();
            throw $th;
        }

        return $this->stdSuccess(message: 'Sign up cancelled');
    }
}

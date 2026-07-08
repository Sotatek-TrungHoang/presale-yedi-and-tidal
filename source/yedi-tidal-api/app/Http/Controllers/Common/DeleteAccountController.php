<?php

namespace App\Http\Controllers\Common;

use App\Http\Controllers\Controller;
use App\Models\Advertiser;
use App\Models\Applicant;
use App\Models\User;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

class DeleteAccountController extends Controller
{
    public function __invoke()
    {
        /** @var User $user */
        $user = Auth::user();

        try {
            DB::beginTransaction();

            $user->email = Str::random(10).'_deleted@example.com';
            $user->first_name = 'Deleted';
            $user->last_name = 'User';
            $user->name = 'Deleted User';
            $user->password = Hash::make(Str::random(32));
            $user->tokens()->delete();
            $user->deviceTokens()->delete();

            $userable = $user->userable;

            if ($userable instanceof Applicant) {

                $userable->applications()->delete();
                $userable->references()->delete();
                $userable->declarationAgreements()->delete();
                $userable->rightToWorkDeclaration()->delete();
                $userable->applicantEvidence()->delete();
                $userable->videoVerifications()->delete();
                $userable->photograph()->delete();
                $userable->evidenceOfId()->delete();
                $userable->address()->delete();
                $userable->payslips()->delete();
                $userable->contracts()->delete();
                $userable->heartedApplicants()->delete();
                $userable->delete();
            } elseif ($userable instanceof Advertiser) {
                $userable->heartedApplicants()->delete();
                $userable->contracts()->delete();
                $userable->photograph()->delete();
                $userable->addresses()->delete();

                foreach ($userable->adverts as $advert) {
                    $advert->applications()->delete();
                    $advert->shifts()->delete();
                    $advert->address()->delete();
                    $advert->documents()->delete();
                    $advert->delete();
                }
                $userable->delete();
            }

            $user->delete();

            DB::commit();
        } catch (\Throwable $th) {
            DB::rollBack();
            throw $th;
        }

        return response()->noContent();
    }
}

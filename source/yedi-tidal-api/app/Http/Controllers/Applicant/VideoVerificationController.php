<?php

namespace App\Http\Controllers\Applicant;

use App\Http\Controllers\Controller;
use App\Http\Controllers\Traits\ApplicantPortalTrait;
use App\Http\Requests\Applicant\VideoVerification\SubmitVideoVerificationRequest;
use App\Http\Resources\Applicants\VideoVerifications\VideoVerificationResource;
use App\Models\Upload;
use App\Models\VideoVerification;

class VideoVerificationController extends Controller
{
    use ApplicantPortalTrait;

    public function __construct()
    {
        //
    }

    public function store()
    {
        $applicant = $this->getApplicant();
        $applicant->videoVerifications()->whereNull('upload_id')->delete();
        $videoVerification = $applicant->videoVerifications()->create();

        return new VideoVerificationResource($videoVerification);
    }

    public function submit(SubmitVideoVerificationRequest $request, VideoVerification $videoVerification)
    {
        $validData = $request->validated();
        $upload = Upload::query()->findOrFail($validData['upload_id']);

        $videoVerification->upload()->associate($upload)->save();
        $upload->owner()->associate($videoVerification)->save();

        return new VideoVerificationResource($videoVerification);
    }
}

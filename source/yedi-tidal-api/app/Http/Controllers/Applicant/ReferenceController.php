<?php

namespace App\Http\Controllers\Applicant;

use App\Enums\ReferenceStatus;
use App\Handlers\References\RequestReferenceHandler;
use App\Http\Controllers\Controller;
use App\Http\Controllers\Traits\ApplicantPortalTrait;
use App\Http\Requests\Applicant\Profile\CreateReferenceRequest;
use App\Http\Resources\Applicants\References\ReferenceCollection;
use App\Http\Resources\Applicants\References\ReferenceResource;
use App\Models\Reference;
use Illuminate\Support\Facades\DB;

class ReferenceController extends Controller
{
    use ApplicantPortalTrait;

    public function __construct(
        protected RequestReferenceHandler $requestReferenceHandler
    ) {}

    public function index()
    {

        $applicant = $this->getApplicant();

        return new ReferenceCollection($applicant->references()->orderBy('id', 'desc')->get());
    }

    public function store(CreateReferenceRequest $request)
    {
        $applicant = $this->getApplicant();

        try {
            DB::beginTransaction();
            $reference = new Reference([
                ...$request->validated(),
                'signature_date' => now(),
                'status' => ReferenceStatus::Created,
            ]);
            $reference->applicant()->associate($applicant);
            $reference->save();

            $this->requestReferenceHandler->handle($reference);

            DB::commit();
        } catch (\Throwable $th) {
            DB::rollBack();
            throw $th;
        }

        return new ReferenceResource($reference);
    }
}

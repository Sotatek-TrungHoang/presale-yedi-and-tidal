<?php

namespace App\Http\Controllers\Public;

use App\Enums\ReferenceStatus;
use App\Handlers\Notifications\NotifyAdminsHandler;
use App\Http\Controllers\Controller;
use App\Http\Requests\Public\CompleteReferenceRequest;
use App\Jobs\CreateReferencePdfJob;
use App\Models\Reference;
use App\Notifications\Admin\NewReferenceProvidedNotification;

class ReferenceController extends Controller
{
    public function __construct(
        protected NotifyAdminsHandler $notifyAdminsHandler
    ) {}

    public function index(Reference $reference)
    {

        if ($reference->status === ReferenceStatus::Created) {
            abort(404);
        }

        if ($reference->status !== ReferenceStatus::SentToReferee) {
            return view('reference-form-complete', compact('reference'));
        }

        return view('reference-form', compact('reference'));
    }

    public function store(CompleteReferenceRequest $request, Reference $reference)
    {
        $reference->fill([
            ...$request->validated(),
            'signature_date' => now(),
            'status' => ReferenceStatus::PendingConfirmation,
        ]);
        $reference->save();

        $this->notifyAdminsHandler->handle(new NewReferenceProvidedNotification($reference));
        CreateReferencePdfJob::dispatch($reference);

        return view('reference-form-complete', compact('reference'));
    }
}

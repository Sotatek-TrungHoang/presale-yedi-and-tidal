<?php

namespace App\Jobs;

use App\Enums\ReferenceStatus;
use App\Handlers\Uploads\CreateUploadFromDataHandler;
use App\Http\Integrations\DocGen\DocGenConnector;
use App\Http\Integrations\DocGen\Requests\GeneratePdfRequest;
use App\Models\Reference;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use Saloon\Exceptions\Request\RequestException;

class CreateReferencePdfJob implements ShouldQueue
{
    use Queueable;

    /**
     * Create a new job instance.
     */
    public function __construct(
        protected Reference $reference,
    ) {
        $this->onQueue('documents');
    }

    /**
     * Execute the job.
     */
    public function handle(
        DocGenConnector $docGenConnector,
        CreateUploadFromDataHandler $createUploadFromDataHandler,
    ): void {

        if ($this->reference->status !== ReferenceStatus::PendingConfirmation) {
            return;
        }

        try {
            DB::beginTransaction();

            try {
                $html = view('pdfs.reference', ['reference' => $this->reference])->render();
                $request = (new GeneratePdfRequest($html))->setFormat('A4')->setLandscape(false);
                $response = $docGenConnector->send($request);
            } catch (RequestException $e) {
                report($e);
                throw $e;
            }

            $upload = $createUploadFromDataHandler->handle(
                data: $response->body(),
                originalFileName: sprintf('%s_%s_reference.pdf', Str::snake($this->reference->name), Str::snake($this->reference->referee_name)),
                mime: 'application/pdf',
                extension: 'pdf',
            );

            $this->reference->upload()->associate($upload);
            $this->reference->save();

            $upload->owner()->associate($this->reference);
            $upload->save();

            DB::commit();
        } catch (\Throwable $th) {
            DB::rollBack();
            throw $th;
        }
    }
}

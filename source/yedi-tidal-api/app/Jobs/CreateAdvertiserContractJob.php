<?php

namespace App\Jobs;

use App\Handlers\Settings\SettingsResolver;
use App\Handlers\Uploads\CreateUploadFromDataHandler;
use App\Http\Integrations\DocGen\DocGenConnector;
use App\Http\Integrations\DocGen\Requests\GeneratePdfRequest;
use App\Models\Advertiser;
use App\Models\Contract;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;
use Illuminate\Support\Facades\DB;

class CreateAdvertiserContractJob implements ShouldQueue
{
    use Queueable;

    /**
     * Create a new job instance.
     */
    public function __construct(
        protected Advertiser $advertiser,
    ) {
        $this->onQueue('documents');
    }

    /**
     * Execute the job.
     */
    public function handle(
        DocGenConnector $docGenConnector,
        CreateUploadFromDataHandler $createUploadFromDataHandler,
        SettingsResolver $settingsResolver,
    ): void {

        $settings = $settingsResolver->resolve();

        $contractWording = $settings->advertiser_contract;
        if (! $contractWording) {
            return;
        }

        $replacements = [
            '{{ADVERTISER_NAME}}' => $this->advertiser->name,
        ];

        foreach ($replacements as $key => $replaceWith) {
            $contractWording = str_replace($key, $replaceWith, $contractWording);
        }

        $month = now()->format('M d');
        $title = sprintf('%s Contract %s', ___('brand'), $month);

        try {
            DB::beginTransaction();

            $html = view('pdfs.advertiser-contract', ['advertiser' => $this->advertiser, 'wording' => $contractWording])->render();
            $request = (new GeneratePdfRequest($html))->setFormat('A4')->setLandscape(false);
            $response = $docGenConnector->send($request);

            $upload = $createUploadFromDataHandler->handlePdf(
                data: $response->body(),
                originalFileName: sprintf('contract_%s_%s_invoice.pdf', $this->advertiser->name, $month),
            );

            $contract = new Contract(['title' => $title]);
            $contract->owner()->associate($this->advertiser);
            $contract->upload()->associate($upload);
            $contract->save();

            $upload->owner()->associate($contract);
            $upload->save();

            DB::commit();
        } catch (\Throwable $th) {
            DB::rollBack();
            throw $th;
        }
    }
}

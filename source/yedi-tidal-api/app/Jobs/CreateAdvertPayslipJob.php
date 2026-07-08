<?php

namespace App\Jobs;

use App\Handlers\Notifications\NotifyApplicantHandler;
use App\Handlers\Uploads\CreateUploadFromDataHandler;
use App\Http\Integrations\DocGen\DocGenConnector;
use App\Http\Integrations\DocGen\Requests\GeneratePdfRequest;
use App\Models\Advert;
use App\Models\Payslip;
use App\Notifications\Applicant\NewPayslipNotification;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;
use Illuminate\Support\Facades\DB;
use Saloon\Exceptions\Request\RequestException;

class CreateAdvertPayslipJob implements ShouldQueue
{
    use Queueable;

    /**
     * Create a new job instance.
     */
    public function __construct(
        protected Advert $advert,
    ) {
        $this->onQueue('documents');
    }

    /**
     * Execute the job.
     */
    public function handle(
        DocGenConnector $docGenConnector,
        CreateUploadFromDataHandler $createUploadFromDataHandler,
        NotifyApplicantHandler $notifyApplicantHandler,
    ): void {

        $application = $this->advert->acceptedApplication;
        if (! $application) {
            return;
        }

        $applicant = $application->applicant;

        if ($this->advert->starts_at->isSameDay($this->advert->ends_at)) {
            $date = $this->advert->starts_at->format('M j Y');
        } else {
            $date = sprintf('%s - %s', $this->advert->starts_at->format('M j'), $this->advert->ends_at->format('M j Y'));
        }

        $title = sprintf('%s (%s)', $this->advert->title, $date);

        try {
            DB::beginTransaction();

            $payslip = new Payslip([
                'title' => $title,
            ]);

            $payslip->advert()->associate($this->advert);
            $payslip->applicant()->associate($applicant);
            $payslip->save();
            $payslip = $payslip->fresh();

            try {
                $html = view('pdfs.payslip', ['payslip' => $payslip])->render();
                $request = (new GeneratePdfRequest($html))->setFormat('A4')->setLandscape(false);
                $response = $docGenConnector->send($request);
            } catch (RequestException $e) {
                report($e);
                throw $e;
            }

            $upload = $createUploadFromDataHandler->handle(
                data: $response->body(),
                originalFileName: sprintf('%s_%s_%s_payslip.pdf', $this->advert->title, $applicant->user?->name ?? '', $this->advert->starts_at->format('Y-m-d')),
                mime: 'application/pdf',
                extension: 'pdf',
            );

            $payslip->upload()->associate($upload);
            $payslip->save();

            $upload->owner()->associate($payslip);
            $upload->save();

            DB::commit();
        } catch (\Throwable $th) {
            DB::rollBack();
            throw $th;
        }

        $notifyApplicantHandler->handle($applicant, new NewPayslipNotification($payslip));
    }
}

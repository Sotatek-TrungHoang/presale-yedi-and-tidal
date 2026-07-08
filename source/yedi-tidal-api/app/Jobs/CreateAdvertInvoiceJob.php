<?php

namespace App\Jobs;

use App\Enums\PayType;
use App\Handlers\Notifications\NotifyAdvertiserHandler;
use App\Handlers\Settings\SettingsResolver;
use App\Handlers\Uploads\CreateUploadFromDataHandler;
use App\Http\Integrations\DocGen\DocGenConnector;
use App\Http\Integrations\DocGen\Requests\GeneratePdfRequest;
use App\Models\Advert;
use App\Models\InvoiceItem;
use App\Notifications\Advertiser\NewInvoiceNotification;
use Brick\Math\RoundingMode;
use Brick\Money\Money;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Foundation\Queue\Queueable;
use Illuminate\Support\Facades\DB;
use Saloon\Exceptions\Request\RequestException;

class CreateAdvertInvoiceJob implements ShouldQueue
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
        NotifyAdvertiserHandler $notifyAdvertiserHandler,
        SettingsResolver $settingsResolver,
    ): void {

        $settings = $settingsResolver->resolve();

        if ($this->advert->starts_at->isSameDay($this->advert->ends_at)) {
            $date = $this->advert->starts_at->format('M j Y');
        } else {
            $date = sprintf('%s - %s', $this->advert->starts_at->format('M j'), $this->advert->ends_at->format('M j Y'));
        }

        $title = sprintf('%s (%s)', $this->advert->title, $date);

        try {
            DB::beginTransaction();

            $items = collect();
            foreach ($this->advert->shifts as $shift) {
                $quantity = $this->advert->advertiser_pay_rate_type === PayType::Hourly ? $shift->hours : 1;
                $items->push(new InvoiceItem([
                    'date' => $shift->starts_at->format('Y-m-d'),
                    'description' => $this->advert->title,
                    'rate_type' => $this->advert->advertiser_pay_rate_type,
                    'rate' => $this->advert->advertiser_pay_rate,
                    'quantity' => $quantity,
                    'amount' => $this->advert->advertiser_pay_rate->multipliedBy($quantity, RoundingMode::HALF_UP),
                ]));
            }

            $subtotal = $items->reduce(fn ($initial, InvoiceItem $carry) => $initial->plus($carry->amount), Money::zero('GBP'));
            $vat = $subtotal->multipliedBy(0.2, RoundingMode::HALF_UP);
            $total = $subtotal->plus($vat);

            $invoice = $this->advert->invoice()->make([
                'title' => $title,
                'due_date' => now()->addDays($settings->invoice_due_date_days)->setTime(0, 0, 0),
                'invoice_due_date_days' => $settings->invoice_due_date_days,
                'invoice_late_payment_charge_percent' => $settings->invoice_late_payment_charge_percent,
                'sub_total' => $subtotal,
                'vat' => $vat,
                'total' => $total,
            ]);
            $invoice->save();

            $invoice->items()->saveMany($items);

            $invoice = $invoice->fresh();

            try {
                $html = view('pdfs.invoice', ['invoice' => $invoice, 'settings' => $settings])->render();
                $request = (new GeneratePdfRequest($html))->setFormat('A4')->setLandscape(false);
                $response = $docGenConnector->send($request);
            } catch (RequestException $e) {
                report($e);
                throw $e;
            }

            $upload = $createUploadFromDataHandler->handle(
                data: $response->body(),
                originalFileName: sprintf('%s_%s_invoice.pdf', $this->advert->title, $this->advert->starts_at->format('Y-m-d')),
                mime: 'application/pdf',
                extension: 'pdf',
            );

            $invoice->upload()->associate($upload);
            $invoice->save();

            $upload->owner()->associate($invoice);
            $upload->save();

            DB::commit();
        } catch (\Throwable $th) {
            DB::rollBack();
            throw $th;
        }

        $notifyAdvertiserHandler->handle($this->advert->advertiser, new NewInvoiceNotification($invoice));
    }
}

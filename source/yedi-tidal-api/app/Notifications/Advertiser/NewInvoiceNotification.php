<?php

namespace App\Notifications\Advertiser;

use App\DTOs\Notifications\FcmNotificationData;
use App\Models\Invoice;
use App\Models\User;
use App\Notifications\AbstractNotification;
use App\Notifications\Channels\FcmChannel;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;

class NewInvoiceNotification extends AbstractNotification implements ShouldQueue
{
    use Queueable;

    /**
     * Create a new notification instance.
     */
    public function __construct(protected Invoice $invoice)
    {
        parent::__construct();
    }

    /**
     * Get the notification's delivery channels.
     *
     * @return array<int, string>
     */
    public function via(object $notifiable): array
    {
        return ['mail', FcmChannel::class];
    }

    /**
     * Get the mail representation of the notification.
     */
    public function toMail(User $user): MailMessage
    {
        return (new MailMessage)
            ->subject($this->subject('New Invoice'))
            ->markdown(
                $this->markdown('advertiser.new-invoice'),
                [
                    'user' => $user,
                    'invoice' => $this->invoice,
                    'url' => $this->invoice->upload->url,
                ]
            );
    }

    public function fcm(): FcmNotificationData
    {
        return new FcmNotificationData(
            title: 'New Invoice',
            body: sprintf("You have a new invoice for your job '%s'", $this->invoice->advert->title),
            data: ['invoice_id' => $this->invoice->id]
        );
    }
}

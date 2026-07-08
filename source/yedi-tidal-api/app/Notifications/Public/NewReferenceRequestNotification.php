<?php

namespace App\Notifications\Public;

use App\Models\Reference;
use App\Notifications\AbstractNotification;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\AnonymousNotifiable;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Support\Facades\URL;

class NewReferenceRequestNotification extends AbstractNotification implements ShouldQueue
{
    use Queueable;

    /**
     * Create a new notification instance.
     */
    public function __construct(protected Reference $reference)
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
        return ['mail'];
    }

    /**
     * Get the mail representation of the notification.
     */
    public function toMail(AnonymousNotifiable $notifiable): MailMessage
    {
        return (new MailMessage)
            ->subject($this->subject('New Reference Request'))
            ->markdown(
                $this->markdown('public.new-reference-request'),
                [
                    'reference' => $this->reference,
                    'url' => URL::signedRoute('reference.show', ['reference' => $this->reference->reference_id]),
                ]
            );
    }
}

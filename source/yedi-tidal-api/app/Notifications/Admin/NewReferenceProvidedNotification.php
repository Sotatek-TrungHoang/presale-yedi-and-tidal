<?php

namespace App\Notifications\Admin;

use App\Models\Reference;
use App\Models\User;
use App\Notifications\AbstractNotification;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;

class NewReferenceProvidedNotification extends AbstractNotification implements ShouldQueue
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
    public function toMail(User $user): MailMessage
    {
        return (new MailMessage)
            ->subject($this->subject('New Reference Provided'))
            ->markdown(
                $this->markdown('admin.new-reference-provided'),
                [
                    'user' => $user,
                    'reference' => $this->reference,
                    'url' => $this->urlService->applicant($this->reference->applicant_id),
                ]
            );
    }
}

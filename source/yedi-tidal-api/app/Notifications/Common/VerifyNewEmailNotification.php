<?php

namespace App\Notifications\Common;

use App\Models\User;
use App\Notifications\AbstractNotification;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\AnonymousNotifiable;
use Illuminate\Notifications\Messages\MailMessage;

class VerifyNewEmailNotification extends AbstractNotification implements ShouldQueue
{
    use Queueable;

    /**
     * Create a new notification instance.
     */
    public function __construct(protected User $user)
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
            ->subject($this->subject('Verify Email Address'))
            ->markdown(
                $this->markdown('common.verify-new-email'),
                [
                    'user' => $this->user,
                    'code' => $this->user->new_email_code,
                ]
            );
    }
}

<?php

namespace App\Notifications\Applicant;

use App\DTOs\Notifications\FcmNotificationData;
use App\Models\User;
use App\Notifications\AbstractNotification;
use App\Notifications\Channels\FcmChannel;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;

class AccountActiveNotification extends AbstractNotification implements ShouldQueue
{
    use Queueable;

    /**
     * Create a new notification instance.
     */
    public function __construct()
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
            ->subject($this->subject('Your account is now active'))
            ->markdown(
                $this->markdown('applicant.account-active'),
                [
                    'user' => $user,
                ]
            );
    }

    public function fcm(): FcmNotificationData
    {
        return new FcmNotificationData(
            title: 'Your account is now active',
            body: sprintf('Your account is now active. Open the app to start applying for jobs now.'),
            data: []
        );
    }
}

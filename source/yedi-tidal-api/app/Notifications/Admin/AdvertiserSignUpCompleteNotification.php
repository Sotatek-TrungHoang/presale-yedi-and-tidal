<?php

namespace App\Notifications\Admin;

use App\Models\Advertiser;
use App\Models\User;
use App\Notifications\AbstractNotification;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;

class AdvertiserSignUpCompleteNotification extends AbstractNotification implements ShouldQueue
{
    use Queueable;

    /**
     * Create a new notification instance.
     */
    public function __construct(protected Advertiser $advertiser)
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
            ->subject($this->subject(sprintf('New %s Registration', ucwords(___('advertiser')))))
            ->markdown(
                $this->markdown('admin.advertiser-sign-up-complete'),
                [
                    'user' => $user,
                    'advertiser' => $this->advertiser,
                    'url' => $this->urlService->advertiser($this->advertiser->id),
                ]
            );
    }
}

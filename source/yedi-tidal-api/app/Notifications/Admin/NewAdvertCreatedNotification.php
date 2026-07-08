<?php

namespace App\Notifications\Admin;

use App\Models\Advert;
use App\Models\User;
use App\Notifications\AbstractNotification;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;

class NewAdvertCreatedNotification extends AbstractNotification implements ShouldQueue
{
    use Queueable;

    /**
     * Create a new notification instance.
     */
    public function __construct(protected Advert $advert)
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
            ->subject($this->subject('New Job Created'))
            ->markdown(
                $this->markdown('admin.new-advert-created'),
                [
                    'user' => $user,
                    'advert' => $this->advert,
                    'url' => $this->urlService->advert($this->advert->id),
                    'advertiser_url' => $this->urlService->advertiser($this->advert->advertiser_id),
                ]
            );
    }
}

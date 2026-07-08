<?php

namespace App\Notifications\Advertiser;

use App\DTOs\Notifications\FcmNotificationData;
use App\Models\Advert;
use App\Models\User;
use App\Notifications\AbstractNotification;
use App\Notifications\Channels\FcmChannel;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;

class AdvertHadNoApplicationsNotification extends AbstractNotification implements ShouldQueue
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
        return ['mail', FcmChannel::class];
    }

    /**
     * Get the mail representation of the notification.
     */
    public function toMail(User $user): MailMessage
    {
        return (new MailMessage)
            ->subject($this->subject('Your Advert Has No Applications'))
            ->markdown(
                $this->markdown('advertiser.advert-had-no-applications'),
                [
                    'user' => $user,
                    'advert' => $this->advert,
                ]
            );
    }

    public function fcm(): FcmNotificationData
    {
        return new FcmNotificationData(
            title: 'Your Advert Had No Applications',
            body: "The application period of your advert '{$this->advert->title}' has ended without any applications.",
            data: ['advert_id' => $this->advert->id]
        );
    }
}

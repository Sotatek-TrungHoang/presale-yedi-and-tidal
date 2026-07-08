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

class AdvertPendingAllocationNotification extends AbstractNotification implements ShouldQueue
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
            ->subject($this->subject('Advert Pending Allocation'))
            ->markdown(
                $this->markdown('advertiser.advert-pending-allocation'),
                [
                    'user' => $user,
                    'advert' => $this->advert,
                ]
            );
    }

    public function fcm(): FcmNotificationData
    {
        return new FcmNotificationData(
            title: 'Advert Pending Allocation',
            body: "The application period for your advert '{$this->advert->title}' has ended.",
            data: ['advert_id' => $this->advert->id]
        );
    }
}

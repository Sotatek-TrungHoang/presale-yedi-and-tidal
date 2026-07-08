<?php

namespace App\Notifications\Advertiser;

use App\DTOs\Notifications\FcmNotificationData;
use App\Models\Application;
use App\Models\User;
use App\Notifications\AbstractNotification;
use App\Notifications\Channels\FcmChannel;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;

class NewApplicationNotification extends AbstractNotification implements ShouldQueue
{
    use Queueable;

    /**
     * Create a new notification instance.
     */
    public function __construct(protected Application $application)
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
            ->subject($this->subject('New Application'))
            ->markdown(
                $this->markdown('advertiser.new-application'),
                [
                    'user' => $user,
                    'application' => $this->application,
                ]
            );
    }

    public function fcm(): FcmNotificationData
    {
        return new FcmNotificationData(
            title: 'New Application',
            body: sprintf("%s has applied for your advert '%s'", $this->application->applicant->user->name, $this->application->advert->title),
            data: ['advert_id' => $this->application->advert_id, 'application_id' => $this->application->id]
        );
    }
}

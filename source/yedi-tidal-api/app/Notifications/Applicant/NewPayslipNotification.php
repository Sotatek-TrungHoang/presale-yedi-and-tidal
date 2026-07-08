<?php

namespace App\Notifications\Applicant;

use App\DTOs\Notifications\FcmNotificationData;
use App\Models\Payslip;
use App\Models\User;
use App\Notifications\AbstractNotification;
use App\Notifications\Channels\FcmChannel;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;

class NewPayslipNotification extends AbstractNotification implements ShouldQueue
{
    use Queueable;

    /**
     * Create a new notification instance.
     */
    public function __construct(protected Payslip $payslip)
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
            ->subject($this->subject('New Payslip'))
            ->markdown(
                $this->markdown('applicant.new-payslip'),
                [
                    'user' => $user,
                    'payslip' => $this->payslip,
                    'url' => $this->payslip->upload->url,
                ]
            );
    }

    public function fcm(): FcmNotificationData
    {
        return new FcmNotificationData(
            title: 'New Payslip',
            body: sprintf("You have a new payslip for job '%s'", $this->payslip->advert->title),
            data: ['payslip_id' => $this->payslip->id]
        );
    }
}

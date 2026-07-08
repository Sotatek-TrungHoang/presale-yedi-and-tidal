<?php

namespace App\Notifications\Admin;

use App\Models\Applicant;
use App\Models\User;
use App\Notifications\AbstractNotification;
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;

class ApplicantSignUpCompleteNotification extends AbstractNotification implements ShouldQueue
{
    use Queueable;

    /**
     * Create a new notification instance.
     */
    public function __construct(protected Applicant $applicant)
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
            ->subject($this->subject(sprintf('New %s Registration', ucwords(___('applicant')))))
            ->markdown(
                $this->markdown('admin.applicant-sign-up-complete'),
                [
                    'user' => $user,
                    'applicant' => $this->applicant,
                    'url' => $this->urlService->applicant($this->applicant->id),
                ]
            );
    }
}

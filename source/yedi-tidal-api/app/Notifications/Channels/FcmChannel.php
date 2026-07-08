<?php

namespace App\Notifications\Channels;

use App\DTOs\Notifications\FcmNotificationData;
use App\Models\User;
use Illuminate\Notifications\Notification;
use Kreait\Firebase\Exception\Messaging as MessagingErrors;
use Kreait\Firebase\Exception\MessagingException;
use Kreait\Firebase\Factory;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification as MessagingNotification;

class FcmChannel
{
    public function send(object $notifiable, Notification $notification): void
    {

        if (! $notifiable instanceof User) {
            return;
        }

        if (! method_exists($notification, 'fcm')) {
            return;
        }

        /** @disregard */
        $data = $notification->fcm($notifiable);

        if (! $data instanceof FcmNotificationData) {
            return;
        }

        $tokens = $notifiable->deviceTokens()
            ->where('last_used', '>', now()->subWeek())
            ->get();

        if ($tokens->isEmpty()) {
            return;
        }

        $credentials = config('services.firebase.credentials');
        if (! $credentials) {
            return;
        }

        $factory = (new Factory)->withServiceAccount($credentials);

        $messaging = $factory->createMessaging();
        $messagingNotification = MessagingNotification::create(
            title: $data->title,
            body: $data->body
        );

        foreach ($tokens as $token) {
            $message = CloudMessage::new()
                ->toToken($token->device_token)
                ->withNotification($messagingNotification)
                ->withData($data->data);
            try {
                $messaging->send($message);
            } catch (MessagingErrors\NotFound $e) {
                // The target device could not be found.
                $token->delete();
            } catch (MessagingErrors\InvalidMessage $e) {
                // The given message is malformatted
                $token->delete();
            } catch (MessagingErrors\ServerUnavailable $e) {
                // The FCM servers are currently unavailable
                report($e);
            } catch (MessagingErrors\ServerError $e) {
                // The FCM servers are down
                report($e);
            } catch (MessagingException $e) {
                // Fallback
                report($e);
            } catch (\Throwable $e) {
                report($e);
            }
        }
    }
}

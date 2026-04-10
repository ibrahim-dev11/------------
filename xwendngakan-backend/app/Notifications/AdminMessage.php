<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Notifications\Notification;
use Kreait\Firebase\Messaging\CloudMessage;

class AdminMessage extends Notification
{
    use Queueable;

    private $title;
    private $body;
    private $data;

    /**
     * Create a new notification instance.
     */
    public function __construct($title, $body, $data = [])
    {
        $this->title = $title;
        $this->body = $body;
        $this->data = $data;
    }

    /**
     * Get the notification's delivery channels.
     *
     * @return array<int, string>
     */
    public function via(object $notifiable): array
    {
        // Always send to database
        $channels = ['database'];

        // If user has FCM token, try to send push notification
        if ($notifiable->fcm_token) {
            $this->sendFcmNotification($notifiable->fcm_token);
        }

        return $channels;
    }

    /**
     * Send FCM push notification manually.
     */
    protected function sendFcmNotification($token)
    {
        try {
            $messaging = app('firebase.messaging');
            
            $message = CloudMessage::fromArray([
                'token' => $token,
                'notification' => [
                    'title' => $this->title,
                    'body' => $this->body,
                ],
                'data' => array_merge($this->data, [
                    'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
                ]),
            ]);

            $messaging->send($message);
        } catch (\Exception $e) {
            \Log::error('FCM Error: ' . $e->getMessage());
        }
    }

    /**
     * Get the array representation of the notification.
     *
     * @return array<string, mixed>
     */
    public function toArray(object $notifiable): array
    {
        return [
            'title' => $this->title,
            'body' => $this->body,
            'data' => $this->data,
        ];
    }
}

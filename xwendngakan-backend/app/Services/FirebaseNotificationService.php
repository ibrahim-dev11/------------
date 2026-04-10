<?php

namespace App\Services;

use Kreait\Firebase\Contract\Messaging;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\TopicManagementError;
use Illuminate\Support\Facades\Log;

class FirebaseNotificationService
{
    protected Messaging $messaging;

    public function __construct(Messaging $messaging)
    {
        $this->messaging = $messaging;
    }

    /**
     * Send notification to a single device token.
     *
     * @param string $token FCM token
     * @param string $title Notification title
     * @param string $body Notification body
     * @param array $data Additional data payload
     * @return bool Success status
     */
    public function sendToToken(
        string $token,
        string $title,
        string $body,
        array $data = []
    ): bool {
        try {
            $message = CloudMessage::fromArray([
                'token' => $token,
                'notification' => [
                    'title' => $title,
                    'body' => $body,
                ],
                'data' => array_merge($data, [
                    'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
                ]),
                'android' => [
                    'priority' => 'high',
                ],
                'apns' => [
                    'headers' => [
                        'apns-priority' => '10',
                    ],
                ],
            ]);

            $this->messaging->send($message);
            return true;
        } catch (\Exception $e) {
            Log::error('Firebase Send Error: ' . $e->getMessage());
            return false;
        }
    }

    /**
     * Send notification to multiple tokens.
     *
     * @param array $tokens Array of FCM tokens
     * @param string $title Notification title
     * @param string $body Notification body
     * @param array $data Additional data payload
     * @return array Result with success count and failed tokens
     */
    public function sendToMultipleTokens(
        array $tokens,
        string $title,
        string $body,
        array $data = []
    ): array {
        $successful = 0;
        $failed = [];

        foreach ($tokens as $token) {
            if (empty($token)) continue;
            if ($this->sendToToken($token, $title, $body, $data)) {
                $successful++;
            } else {
                $failed[] = $token;
            }
        }

        return [
            'successful' => $successful,
            'failed' => $failed,
            'total' => count($tokens),
        ];
    }

    /**
     * Send notification to a topic.
     *
     * @param string $topic Topic name
     * @param string $title Notification title
     * @param string $body Notification body
     * @param array $data Additional data payload
     * @return bool Success status
     */
    public function sendToTopic(
        string $topic,
        string $title,
        string $body,
        array $data = []
    ): bool {
        try {
            $message = CloudMessage::fromArray([
                'topic' => $topic,
                'notification' => [
                    'title' => $title,
                    'body' => $body,
                ],
                'data' => array_merge($data, [
                    'click_action' => 'FLUTTER_NOTIFICATION_CLICK',
                ]),
            ]);

            $this->messaging->send($message);
            return true;
        } catch (\Exception $e) {
            Log::error('Firebase Topic Send Error: ' . $e->getMessage());
            return false;
        }
    }

    /**
     * Subscribe tokens to a topic.
     *
     * @param string $topic Topic name
     * @param array $tokens Array of FCM tokens
     * @return bool Success status
     */
    public function subscribeToTopic(string $topic, array $tokens): bool
    {
        try {
            $this->messaging->subscribeToTopic($topic, ...$tokens);
            return true;
        } catch (TopicManagementError $e) {
            Log::error('Firebase Subscribe Error: ' . $e->getMessage());
            return false;
        }
    }

    /**
     * Unsubscribe tokens from a topic.
     *
     * @param string $topic Topic name
     * @param array $tokens Array of FCM tokens
     * @return bool Success status
     */
    public function unsubscribeFromTopic(string $topic, array $tokens): bool
    {
        try {
            $this->messaging->unsubscribeFromTopic($topic, ...$tokens);
            return true;
        } catch (TopicManagementError $e) {
            Log::error('Firebase Unsubscribe Error: ' . $e->getMessage());
            return false;
        }
    }
}

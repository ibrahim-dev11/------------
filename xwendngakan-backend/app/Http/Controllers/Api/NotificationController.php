<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Services\FirebaseNotificationService;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    protected FirebaseNotificationService $firebaseService;

    public function __construct(FirebaseNotificationService $firebaseService)
    {
        $this->firebaseService = $firebaseService;
    }

    /**
     * Get user notifications.
     */
    public function index(Request $request)
    {
        $notifications = $request->user()->notifications;
        
        return response()->json([
            'success' => true,
            'data' => $notifications
        ]);
    }

    /**
     * Mark all as read.
     */
    public function markAllAsRead(Request $request)
    {
        $request->user()->unreadNotifications->markAsRead();
        
        return response()->json([
            'success' => true,
            'message' => 'All marked as read'
        ]);
    }

    /**
     * Mark specific notification as read.
     */
    public function markAsRead(Request $request, $id)
    {
        $notification = $request->user()->notifications()->where('id', $id)->first();
        
        if ($notification) {
            $notification->markAsRead();
        }
        
        return response()->json([
            'success' => true,
            'message' => 'Marked as read'
        ]);
    }

    /**
     * Delete a notification.
     */
    public function destroy(Request $request, $id)
    {
        $request->user()->notifications()->where('id', $id)->delete();
        
        return response()->json([
            'success' => true,
            'message' => 'Notification deleted'
        ]);
    }

    /**
     * Send notification to a specific user (Admin).
     * 
     * POST /api/admin/notifications/send-to-user
     */
    public function sendToUser(Request $request)
    {
        $request->validate([
            'user_id' => 'required|exists:users,id',
            'title' => 'required|string|max:150',
            'body' => 'required|string|max:240',
            'data' => 'sometimes|array',
        ]);

        $user = User::findOrFail($request->user_id);

        if (!$user->fcm_token || !$user->notifications_enabled) {
            return response()->json([
                'success' => false,
                'message' => 'ئەو بەکارهێنەرە FCM تۆکنی نیە یان ئاگادارکردنەوەی ناچالاکە',
            ], 400);
        }

        $success = $this->firebaseService->sendToToken(
            $user->fcm_token,
            $request->title,
            $request->body,
            $request->data ?? []
        );

        if ($success) {
            // Save to database for history
            $user->notify(new \App\Notifications\AdminMessage(
                $request->title,
                $request->body,
                $request->data ?? []
            ));

            return response()->json([
                'success' => true,
                'message' => 'ئاگادارکردنەوە بۆ بەکارهێنەر نێرێ',
            ]);
        }

        return response()->json([
            'success' => false,
            'message' => 'هەڵەیەک لە نێردنی ئاگادارکردنەوە ڕوویدا',
        ], 500);
    }

    /**
     * Send notification to multiple users (Admin).
     * 
     * POST /api/admin/notifications/send-to-users
     */
    public function sendToMultipleUsers(Request $request)
    {
        $request->validate([
            'user_ids' => 'required|array|min:1',
            'user_ids.*' => 'exists:users,id',
            'title' => 'required|string|max:150',
            'body' => 'required|string|max:240',
            'data' => 'sometimes|array',
        ]);

        $users = User::whereIn('id', $request->user_ids)
            ->where('notifications_enabled', true)
            ->whereNotNull('fcm_token')
            ->get();

        if ($users->isEmpty()) {
            return response()->json([
                'success' => false,
                'message' => 'هیچ بەکارهێنەرێک نەدۆزرایەوە کە ئاگادارکردنەوەی پێ دەبێت',
            ], 400);
        }

        $tokens = $users->pluck('fcm_token')->toArray();
        $result = $this->firebaseService->sendToMultipleTokens(
            $tokens,
            $request->title,
            $request->body,
            $request->data ?? []
        );

        // Save to database for each user
        foreach ($users as $user) {
            $user->notify(new \App\Notifications\AdminMessage(
                $request->title,
                $request->body,
                $request->data ?? []
            ));
        }

        return response()->json([
            'success' => true,
            'message' => "ئاگادارکردنەوە بۆ {$result['successful']} بەکارهێنەر نێرێ",
            'result' => $result,
        ]);
    }

    /**
     * Send notification to all users (Admin - Broadcast).
     * 
     * POST /api/admin/notifications/broadcast
     */
    public function broadcastNotification(Request $request)
    {
        $request->validate([
            'title' => 'required|string|max:150',
            'body' => 'required|string|max:240',
            'data' => 'sometimes|array',
        ]);

        $users = User::where('notifications_enabled', true)
            ->whereNotNull('fcm_token')
            ->get();

        if ($users->isEmpty()) {
            return response()->json([
                'success' => false,
                'message' => 'هیچ بەکارهێنەرێک نەدۆزرایەوە',
            ], 400);
        }

        $tokens = $users->pluck('fcm_token')->toArray();
        $result = $this->firebaseService->sendToMultipleTokens(
            $tokens,
            $request->title,
            $request->body,
            $request->data ?? []
        );

        // Optionally save to database (consider performance for large user bases)
        foreach ($users as $user) {
            $user->notify(new \App\Notifications\AdminMessage(
                $request->title,
                $request->body,
                $request->data ?? []
            ));
        }

        return response()->json([
            'success' => true,
            'message' => "بڵاوکردنەوەی ئاگادارکردنەوە بۆ {$result['successful']} بەکارهێنەر",
            'result' => $result,
        ]);
    }

    /**
     * Subscribe users to a topic.
     * 
     * POST /api/admin/notifications/subscribe-topic
     */
    public function subscribeTopic(Request $request)
    {
        $request->validate([
            'topic' => 'required|string|max:255',
            'user_ids' => 'required|array|min:1',
            'user_ids.*' => 'exists:users,id',
        ]);

        $tokens = User::whereIn('id', $request->user_ids)
            ->whereNotNull('fcm_token')
            ->pluck('fcm_token')
            ->toArray();

        if (empty($tokens)) {
            return response()->json([
                'success' => false,
                'message' => 'هیچ وەرگرێک نەدۆزرایەوە',
            ], 400);
        }

        $success = $this->firebaseService->subscribeToTopic($request->topic, $tokens);

        return response()->json([
            'success' => $success,
            'message' => $success 
                ? "بەکارهێنەر بۆ {$request->topic} بابەتی تۆمار کران"
                : "هەڵەیەک لە تۆماری بابەتی ڕوویدا",
        ]);
    }

    /**
     * Send notification to a topic.
     * 
     * POST /api/admin/notifications/send-to-topic
     */
    public function sendToTopic(Request $request)
    {
        $request->validate([
            'topic' => 'required|string|max:255',
            'title' => 'required|string|max:150',
            'body' => 'required|string|max:240',
            'data' => 'sometimes|array',
        ]);

        $success = $this->firebaseService->sendToTopic(
            $request->topic,
            $request->title,
            $request->body,
            $request->data ?? []
        );

        return response()->json([
            'success' => $success,
            'message' => $success
                ? "ئاگادارکردنەوە بۆ {$request->topic} بابەت نێرێ"
                : "هەڵەیەک لە نێردن ڕوویدا",
        ]);
    }
}

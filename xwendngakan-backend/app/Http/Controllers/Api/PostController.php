<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Post;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Intervention\Image\Laravel\Facades\Image;

use App\Services\FirebaseNotificationService;
use App\Models\User;

class PostController extends Controller
{
    protected FirebaseNotificationService $firebaseService;

    public function __construct(FirebaseNotificationService $firebaseService)
    {
        $this->firebaseService = $firebaseService;
    }
    /**
     * Get posts for a specific institution (only approved ones for public).
     */
    public function index(Request $request, int $institutionId)
    {
        $query = Post::where('institution_id', $institutionId)
            ->where('approved', true)
            ->with(['user', 'institution'])
            ->orderBy('created_at', 'desc');

        return response()->json([
            'success' => true,
            'data'    => $query->get(),
        ]);
    }

    /**
     * Create a new post for an institution.
     */
    public function store(Request $request, int $institutionId)
    {
        $institution = \App\Models\Institution::findOrFail($institutionId);

        // Only admins or the institution owner can create posts
        if (!$request->user()->is_admin && $request->user()->id !== $institution->user_id) {
            return response()->json([
                'success' => false,
                'message' => 'ڕێگەپێدراو نیت بۆ دروستکردنی پۆست بۆ ئەم دامەزراوەیە.',
            ], 403);
        }

        $request->validate([
            'title'   => 'nullable|string|max:255',
            'content' => 'nullable|string|max:5000',
            'image'   => 'nullable|image|max:4096',
        ]);

        $data = [
            'institution_id' => $institutionId,
            'user_id'        => $request->user()->id,
            'title'          => $request->input('title', ''),
            'content'        => $request->input('content', ''),
            'approved'       => true, // Owner/admin posts are auto-approved
        ];

        // Handle image upload
        if ($request->hasFile('image')) {
            $file = $request->file('image');
            $filename = 'posts/' . uniqid() . '.jpg';

            $img = Image::read($file)
                ->scaleDown(width: 800)
                ->toJpeg(quality: 80);

            Storage::disk('public')->put($filename, (string) $img);
            $data['image'] = $filename;
        }

        $post = Post::create($data);
        $post->load(['user', 'institution']);

        // Send notification to all users who have notifications enabled
        $this->sendNewPostNotification($post);

        return response()->json([
            'success' => true,
            'message' => 'پۆستەکە بەسەرکەوتوویی بڵاوکرایەوە.',
            'data'    => $post,
        ], 201);
    }

    /**
     * Send notification about the new post.
     */
    protected function sendNewPostNotification(Post $post)
    {
        $institutionName = $post->institution->nku ?? $post->institution->nen ?? 'دامەزراوەکە';
        
        $title = "پۆستێکی نوێ بڵاوکرایەوە";
        $body = "{$institutionName} بابەتێکی نوێی بڵاوکردەوە: " . ($post->title ?: 'پۆستێکی نوێ');

        // We can send to all users with notifications enabled
        $users = User::where('notifications_enabled', true)
            ->whereNotNull('fcm_token')
            ->get();
 
        if ($users->isNotEmpty()) {
            $tokens = $users->pluck('fcm_token')->toArray();
            $this->firebaseService->sendToMultipleTokens(
                $tokens,
                $title,
                $body,
                [
                    'type' => 'post',
                    'post_id' => (string) $post->id,
                    'institution_id' => (string) $post->institution_id,
                ]
            );

            // Also save to database notifications for each user
            foreach ($users as $user) {
                $user->notify(new \App\Notifications\AdminMessage(
                    $title,
                    $body,
                    [
                        'type' => 'post',
                        'post_id' => (string) $post->id,
                        'institution_id' => (string) $post->institution_id,
                    ]
                ));
            }
        }
    }

    /**
     * Update a post.
     */
    public function update(Request $request, int $id)
    {
        $post = Post::findOrFail($id);

        // Only post owner or admin can update
        if ($request->user()->id !== $post->user_id && !$request->user()->is_admin) {
            return response()->json([
                'success' => false,
                'message' => 'ڕێگەپێنەدراوە.',
            ], 403);
        }

        $request->validate([
            'title'   => 'nullable|string|max:255',
            'content' => 'nullable|string|max:5000',
        ]);

        $post->update([
            'title'   => $request->input('title', $post->title),
            'content' => $request->input('content', $post->content),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'پۆستەکە نوێکرایەوە.',
            'data'    => $post,
        ]);
    }

    /**
     * Delete a post.
     */
    public function destroy(Request $request, int $id)
    {
        $post = Post::findOrFail($id);

        // Only post owner or admin can delete
        if ($request->user()->id !== $post->user_id && !$request->user()->is_admin) {
            return response()->json([
                'success' => false,
                'message' => 'ڕێگەپێنەدراوە.',
            ], 403);
        }

        // Delete associated image if exists
        if ($post->image && Storage::disk('public')->exists($post->image)) {
            Storage::disk('public')->delete($post->image);
        }

        $post->delete();

        return response()->json([
            'success' => true,
            'message' => 'پۆستەکە سڕایەوە.',
        ]);
    }

    // ── Admin Methods ──

    /**
     * Get all posts (admin) with optional filter.
     */
    public function adminIndex(Request $request)
    {
        $query = Post::with(['user', 'institution'])
            ->orderBy('created_at', 'desc');

        // Filter by approval status
        if ($request->has('approved')) {
            $query->where('approved', (bool) $request->approved);
        }

        return response()->json([
            'success' => true,
            'data'    => $query->get(),
        ]);
    }

    /**
     * Toggle post approval (admin).
     */
    public function toggleApproval(int $id)
    {
        $post = Post::findOrFail($id);
        $post->approved = !$post->approved;
        $post->save();

        return response()->json([
            'success'  => true,
            'message'  => $post->approved ? 'پۆستەکە پەسەندکرا.' : 'پۆستەکە ڕەتکرایەوە.',
            'approved' => $post->approved,
            'data'     => $post,
        ]);
    }
}

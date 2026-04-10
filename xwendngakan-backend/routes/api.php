<?php

use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\InstitutionController;
use App\Http\Controllers\Api\FavoriteController;
use App\Http\Controllers\Api\ReportController;
use App\Http\Controllers\Api\AppVersionController;
use App\Http\Controllers\Api\PostController;
use App\Http\Controllers\Api\CvController;
use App\Http\Controllers\Api\TeacherController;
use App\Http\Controllers\Api\NotificationController;
use App\Models\InstitutionType;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Public Routes
|--------------------------------------------------------------------------
*/
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// Password Reset (public)
Route::post('/forgot-password', [AuthController::class, 'forgotPassword']);
Route::post('/verify-reset-code', [AuthController::class, 'verifyResetCode']);
Route::post('/reset-password', [AuthController::class, 'resetPassword']);

// App version check (public)
Route::post('/check-update', [AppVersionController::class, 'check']);

// Public institution browsing
Route::get('/institutions', [InstitutionController::class, 'index']);
Route::get('/institutions/{id}', [InstitutionController::class, 'show']);
Route::get('/stats', [InstitutionController::class, 'stats']);

// Report types (public)
Route::get('/report-types', [ReportController::class, 'types']);

// Report institution (can be anonymous)
Route::post('/institutions/{id}/report', [ReportController::class, 'store']);

// Public posts for an institution
Route::get('/institutions/{institutionId}/posts', [PostController::class, 'index']);

// CV Routes (public)
Route::get('/cvs', [CvController::class, 'index']);
Route::post('/cvs', [CvController::class, 'store']);
Route::get('/cvs/{id}', [CvController::class, 'show']);
Route::get('/cv-stats', [CvController::class, 'stats']);
Route::get('/education-levels', [CvController::class, 'educationLevels']);

// Teacher Routes (public)
Route::get('/teachers', [TeacherController::class, 'index']);
Route::post('/teachers', [TeacherController::class, 'store']);
Route::get('/teachers/{id}', [TeacherController::class, 'show']);
Route::get('/teacher-stats', [TeacherController::class, 'stats']);


// Institution types
Route::get('/institution-types', function () {
    $types = InstitutionType::active()->ordered()->get(['key', 'name', 'name_en', 'name_ar', 'emoji', 'icon']);
    return response()->json([
        'success' => true,
        'data' => $types,
    ]);
});

// Unified app data — single endpoint for types + categories
Route::get('/app-data', function () {
    $types = InstitutionType::active()->ordered()->get(['key', 'name', 'name_en', 'name_ar', 'emoji', 'icon']);

    return response()->json([
        'success' => true,
        'data' => [
            'types' => $types,
        ], 
    ]);
});

/*
|--------------------------------------------------------------------------
| Protected Routes (require Sanctum token)
|--------------------------------------------------------------------------
*/
Route::middleware('auth:sanctum')->group(function () {
    // Auth
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user', [AuthController::class, 'user']);
    Route::post('/fcm-token', [AuthController::class, 'updateFcmToken']);
    Route::post('/toggle-notifications', [AuthController::class, 'toggleNotifications']);

    // Teacher Requests
    Route::get('/my-teacher-request', function () {
        $request = \App\Models\TeacherRequest::where('user_id', auth()->id())->latest()->first();
        return response()->json([
            'success' => true,
            'data' => $request
        ]);
    });

    Route::post('/teacher-requests', function (\Illuminate\Http\Request $request) {
        $request->validate([
            'name' => 'required|string',
            'phone' => 'required|string',
            'message' => 'nullable|string',
        ]);
        
        // Update existing or create new
        $teacherRequest = \App\Models\TeacherRequest::updateOrCreate(
            ['user_id' => auth()->id()],
            [
                'name' => $request->name,
                'phone' => $request->phone,
                'message' => $request->message,
                'status' => 'pending'
            ]
        );
        
        return response()->json([
            'success' => true,
            'message' => 'داواکاریەکەت بە سەرکەوتوویی نێردرا، بە زوترین کات پەیوەندیت پێوە دەکرێت',
            'data' => $teacherRequest
        ]);
    });

    Route::delete('/teacher-requests/clear', function () {
        \App\Models\TeacherRequest::where('user_id', auth()->id())->delete();
        return response()->json(['success' => true]);
    });

    // Institution Requests
    Route::get('/my-institution-request', function () {
        $request = \App\Models\InstitutionRequest::where('user_id', auth()->id())->latest()->first();
        return response()->json([
            'success' => true,
            'data' => $request
        ]);
    });

    Route::get('/my-institution', function () {
        $inst = \App\Models\Institution::where('user_id', auth()->id())->first();
        return response()->json([
            'success' => true,
            'data' => $inst
        ]);
    });

    Route::post('/institution-requests', function (Illuminate\Http\Request $request) {
        $request->validate([
            'name' => 'required',
            'phone' => 'required',
        ]);

        $instReq = \App\Models\InstitutionRequest::updateOrCreate(
            ['user_id' => auth()->id()],
            [
                'name' => $request->name,
                'phone' => $request->phone,
                'message' => $request->message,
                'status' => 'pending'
            ]
        );

        return response()->json([
            'success' => true,
            'message' => 'داواکاریەکەت بە سەرکەوتوویی نێردرا، بە زوترین کات پەیوەندیت پێوە دەکرێت',
            'data' => $instReq
        ]);
    });

    Route::delete('/institution-requests/clear', function () {
        \App\Models\InstitutionRequest::where('user_id', auth()->id())->delete();
        return response()->json(['success' => true]);
    });

    // Institution CRUD
    Route::post('/institutions', [InstitutionController::class, 'store']);
    Route::put('/institutions/{id}', [InstitutionController::class, 'update']);
    Route::delete('/institutions/{id}', [InstitutionController::class, 'destroy']);

    // Favorites
    Route::get('/favorites', [FavoriteController::class, 'index']);
    Route::get('/favorites/ids', [FavoriteController::class, 'ids']);
    Route::post('/favorites/{institutionId}', [FavoriteController::class, 'store']);
    Route::delete('/favorites/{institutionId}', [FavoriteController::class, 'destroy']);
    Route::post('/favorites/{institutionId}/toggle', [FavoriteController::class, 'toggle']);

    // Posts CRUD
    Route::post('/institutions/{institutionId}/posts', [PostController::class, 'store']);
    Route::put('/posts/{id}', [PostController::class, 'update']);
    Route::delete('/posts/{id}', [PostController::class, 'destroy']);
    
    // Admin: Post management
    Route::get('/admin/posts', [PostController::class, 'adminIndex']);
    Route::post('/admin/posts/{id}/toggle-approval', [PostController::class, 'toggleApproval']);

    // Admin: Institution management
    Route::get('/admin/institutions', [InstitutionController::class, 'adminIndex']);
    Route::post('/admin/institutions/{id}/toggle-approval', [InstitutionController::class, 'toggleApproval']);
    Route::delete('/admin/institutions/{id}', [InstitutionController::class, 'adminDestroy']);

    // Admin: Report management
    Route::get('/admin/reports', [ReportController::class, 'adminIndex']);
    Route::patch('/admin/reports/{id}/status', [ReportController::class, 'updateStatus']);
    Route::delete('/admin/reports/{id}', [ReportController::class, 'adminDestroy']);

    // Admin: CV management
    Route::get('/admin/cvs', [CvController::class, 'adminIndex']);
    Route::post('/admin/cvs/{id}/toggle-review', [CvController::class, 'toggleReview']);
    Route::delete('/admin/cvs/{id}', [CvController::class, 'adminDestroy']);

    // Admin: Teacher management
    Route::get('/admin/teachers', [TeacherController::class, 'adminIndex']);
    Route::post('/admin/teachers/{id}/toggle-approval', [TeacherController::class, 'toggleApproval']);
    Route::delete('/admin/teachers/{id}', [TeacherController::class, 'adminDestroy']);

    // Notifications
    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::post('/notifications/mark-read', [NotificationController::class, 'markAllAsRead']);
    Route::post('/notifications/{id}/mark-read', [NotificationController::class, 'markAsRead']);
    Route::delete('/notifications/{id}', [NotificationController::class, 'destroy']);

    // Admin: Send Notifications via Firebase
    Route::post('/admin/notifications/send-to-user', [NotificationController::class, 'sendToUser']);
    Route::post('/admin/notifications/send-to-users', [NotificationController::class, 'sendToMultipleUsers']);
    Route::post('/admin/notifications/broadcast', [NotificationController::class, 'broadcastNotification']);
    Route::post('/admin/notifications/subscribe-topic', [NotificationController::class, 'subscribeTopic']);
    Route::post('/admin/notifications/send-to-topic', [NotificationController::class, 'sendToTopic']);
});
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Teacher;
use Illuminate\Http\Request;

class TeacherController extends Controller
{
    /**
     * Get all teachers (with optional filters)
     */
    public function index(Request $request)
    {
        $query = Teacher::query()->where('is_approved', true)->latest();

        // Filter by type
        if ($request->filled('type')) {
            $query->where('type', $request->type);
        }

        // Filter by city
        if ($request->filled('city')) {
            $query->where('city', 'like', '%' . $request->city . '%');
        }

        // Search
        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('about', 'like', "%{$search}%")
                  ->orWhere('city', 'like', "%{$search}%");
            });
        }

        $teachers = $query->paginate(20);

        return response()->json([
            'success' => true,
            'data' => $teachers->items(),
            'meta' => [
                'current_page' => $teachers->currentPage(),
                'last_page' => $teachers->lastPage(),
                'total' => $teachers->total(),
            ],
        ]);
    }

    /**
     * Store a new teacher
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'phone' => 'required|string|max:20',
            'subject' => 'nullable|string|max:200',
            'type' => 'required|in:university,school',
            'city' => 'required|string|max:100',
            'experience_years' => 'nullable|integer|min:0|max:60',
            'hourly_rate' => 'nullable|integer|min:0',
            'about' => 'nullable|string|max:2000',
            'video_url' => 'nullable|url|max:500',
            'facebook_url' => 'nullable|url|max:500',
            'photo' => 'nullable|image|mimes:jpeg,png,jpg,webp|max:2048',
            'subject_photo' => 'nullable|image|mimes:jpeg,png,jpg,webp|max:2048',
        ]);

        // Handle photo uploads
        if ($request->hasFile('photo')) {
            $validated['photo'] = $request->file('photo')->store('teachers', 'public');
        }
        if ($request->hasFile('subject_photo')) {
            $validated['subject_photo'] = $request->file('subject_photo')->store('teachers', 'public');
        }

        $teacher = Teacher::create($validated);

        return response()->json([
            'success' => true,
            'message' => 'سوپاس! تۆمارکردنت بە سەرکەوتوویی ئەنجامدرا. دوای پەسەندکردنی ئەدمین زانیاریەکانت بڵاو دەبێتەوە.',
            'data' => $teacher,
        ], 201);
    }

    /**
     * Show a single teacher
     */
    public function show(int $id)
    {
        $teacher = Teacher::findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => $teacher,
        ]);
    }

    /**
     * Get teacher stats
     */
    public function stats()
    {
        return response()->json([
            'success' => true,
            'data' => [
                'total' => Teacher::where('is_approved', true)->count(),
                'university' => Teacher::where('is_approved', true)->where('type', 'university')->count(),
                'school' => Teacher::where('is_approved', true)->where('type', 'school')->count(),
            ],
        ]);
    }

    /**
     * Admin: Get all teachers
     */
    public function adminIndex(Request $request)
    {
        $query = Teacher::latest();

        if ($request->filled('type')) {
            $query->where('type', $request->type);
        }

        $teachers = $query->paginate(20);

        return response()->json([
            'success' => true,
            'data' => $teachers->items(),
            'meta' => [
                'current_page' => $teachers->currentPage(),
                'last_page' => $teachers->lastPage(),
                'total' => $teachers->total(),
            ],
        ]);
    }

    /**
     * Admin: Toggle teacher approval
     */
    public function toggleApproval(int $id)
    {
        $teacher = Teacher::findOrFail($id);
        $teacher->is_approved = !$teacher->is_approved;
        $teacher->save();

        return response()->json([
            'success' => true,
            'data' => $teacher,
            'message' => $teacher->is_approved ? 'ماموستا پەسەندکرا.' : 'ماموستا لاێبرا.',
        ]);
    }

    /**
     * Admin: Delete a teacher
     */
    public function adminDestroy(int $id)
    {
        $teacher = Teacher::findOrFail($id);

        if ($teacher->photo) {
            \Illuminate\Support\Facades\Storage::disk('public')->delete($teacher->photo);
        }

        $teacher->delete();

        return response()->json([
            'success' => true,
            'message' => 'ماموستا سڕایەوە.',
        ]);
    }
}

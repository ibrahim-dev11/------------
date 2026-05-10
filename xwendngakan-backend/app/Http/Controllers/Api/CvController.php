<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Cv;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;

class CvController extends Controller
{
    /**
     * Get all CVs (with optional filters)
     */
    public function index(Request $request)
    {
        $query = Cv::query()->latest();

        // Filter by city
        if ($request->filled('city')) {
            $query->where('city', 'like', '%' . $request->city . '%');
        }

        // Filter by field
        if ($request->filled('field')) {
            $query->where('field', 'like', '%' . $request->field . '%');
        }

        // Filter by education level
        if ($request->filled('education_level')) {
            $query->where('education_level', $request->education_level);
        }

        // Search
        if ($request->filled('search')) {
            $search = $request->search;
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('field', 'like', "%{$search}%")
                  ->orWhere('skills', 'like', "%{$search}%");
            });
        }

        $cvs = $query->paginate(20);

        return response()->json([
            'success' => true,
            'data' => $cvs->items(),
            'meta' => [
                'current_page' => $cvs->currentPage(),
                'last_page' => $cvs->lastPage(),
                'total' => $cvs->total(),
            ],
        ]);
    }

    /**
     * Store a new CV
     */
    public function store(Request $request)
    {
        $validated = $request->validate([
            'name' => 'required|string|max:255',
            'phone' => 'required|string|max:20',
            'email' => 'nullable|email|max:255',
            'city' => 'required|string|max:100',
            'age' => 'nullable|integer|min:15|max:100',
            'gender' => 'nullable|in:male,female,other',
            'graduation_year' => 'nullable|string|max:10',
            'field' => 'required|string|max:255',
            'education_level' => 'nullable|string|max:100',
            'experience' => 'nullable|string|max:2000',
            'skills' => 'nullable|string|max:1000',
            'languages' => 'nullable|string|max:500',
            'notes' => 'nullable|string|max:1000',
            'photo' => 'nullable|image|mimes:jpeg,png,jpg,webp|max:2048',
        ]);

        // Handle photo upload
        if ($request->hasFile('photo')) {
            $validated['photo'] = $request->file('photo')->store('cvs', 'public');
        }

        $cv = Cv::create($validated);

        return response()->json([
            'success' => true,
            'message' => 'سوپاس! CVکەت بە سەرکەوتوویی تۆمارکرا.',
            'data' => $cv,
        ], 201);
    }

    /**
     * Show a single CV
     */
    public function show(int $id)
    {
        $cv = Cv::findOrFail($id);

        return response()->json([
            'success' => true,
            'data' => $cv,
        ]);
    }

    /**
     * Get CV stats
     */
    public function stats()
    {
        return response()->json([
            'success' => true,
            'data' => [
                'total' => Cv::count(),
                'reviewed' => Cv::where('is_reviewed', true)->count(),
                'pending' => Cv::where('is_reviewed', false)->count(),
                'today' => Cv::whereDate('created_at', today())->count(),
                'this_week' => Cv::whereBetween('created_at', [now()->startOfWeek(), now()->endOfWeek()])->count(),
            ],
        ]);
    }

    /**
     * Get education levels for dropdown
     */
    public function educationLevels()
    {
        return response()->json([
            'success' => true,
            'data' => [
                ['key' => 'first_year', 'name' => 'پۆلی یەکەم'],
                ['key' => 'second_year', 'name' => 'پۆلی دووەم'],
                ['key' => 'third_year', 'name' => 'پۆلی سێیەم'],
                ['key' => 'fourth_year', 'name' => 'پۆلی چوارەم'],
                ['key' => 'graduate', 'name' => 'دەرچوو'],
                ['key' => 'masters', 'name' => 'ماستەر'],
                ['key' => 'phd', 'name' => 'دکتۆرا'],
            ],
        ]);
    }

    /**
     * Admin: Get all CVs (unfiltered, with review status)
     */
    public function adminIndex(Request $request)
    {
        $query = Cv::latest();

        $reviewed = $request->get('reviewed');
        if ($reviewed === '1' || $reviewed === 'true') {
            $query->where('is_reviewed', true);
        } elseif ($reviewed === '0' || $reviewed === 'false') {
            $query->where('is_reviewed', false);
        }

        $cvs = $query->paginate(20);

        return response()->json([
            'success' => true,
            'data' => $cvs->items(),
            'meta' => [
                'current_page' => $cvs->currentPage(),
                'last_page'    => $cvs->lastPage(),
                'total'        => $cvs->total(),
                'pending'      => Cv::where('is_reviewed', false)->count(),
                'reviewed'     => Cv::where('is_reviewed', true)->count(),
            ],
        ]);
    }

    /**
     * Admin: Toggle CV review status.
     */
    public function toggleReview(int $id)
    {
        $cv = Cv::findOrFail($id);
        $cv->is_reviewed = !$cv->is_reviewed;
        $cv->save();

        return response()->json([
            'success' => true,
            'data'    => $cv,
            'message' => $cv->is_reviewed ? 'CV پشکنرا.' : 'CV گەڕایەوە بۆ چاوەڕوانکردن.',
        ]);
    }

    /**
     * Admin: Delete a CV.
     */
    public function adminDestroy(int $id)
    {
        $cv = Cv::findOrFail($id);

        // Delete photo if exists
        if ($cv->photo) {
            \Illuminate\Support\Facades\Storage::disk('public')->delete($cv->photo);
        }

        $cv->delete();

        return response()->json([
            'success' => true,
            'message' => 'CV سڕایەوە.',
        ]);
    }
}

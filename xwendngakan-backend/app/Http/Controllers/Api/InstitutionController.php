<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Institution;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Intervention\Image\Laravel\Facades\Image;

class InstitutionController extends Controller
{
    /**
     * Get all approved institutions (public) with optional pagination.
     */
    public function index(Request $request)
    {
        $query = Institution::where('approved', true);

        // Filter by type
        if ($request->has('type') && $request->type !== 'all') {
            $query->where('type', $request->type);
        }

        // Filter by city
        if ($request->has('city') && $request->city !== 'all') {
            $query->where('city', $request->city);
        }

        // Search
        if ($request->has('search') && $request->search) {
            $s = $request->search;
            $query->where(function ($q) use ($s) {
                $q->where('nku', 'like', "%$s%")
                  ->orWhere('nen', 'like', "%$s%")
                  ->orWhere('nar', 'like', "%$s%")
                  ->orWhere('city', 'like', "%$s%");
            });
        }

        // Sort
        $sort = $request->get('sort', 'newest');
        match ($sort) {
            'oldest' => $query->orderBy('created_at', 'asc'),
            'name'   => $query->orderBy('nku', 'asc'),
            default  => $query->orderBy('created_at', 'desc'),
        };

        // Pagination (optional - if page parameter is provided)
        if ($request->has('page')) {
            $perPage = min((int) $request->get('per_page', 20), 100);
            $paginated = $query->paginate($perPage);

            return response()->json([
                'success' => true,
                'data'    => $paginated->items(),
                'meta'    => [
                    'current_page' => $paginated->currentPage(),
                    'last_page'    => $paginated->lastPage(),
                    'per_page'     => $paginated->perPage(),
                    'total'        => $paginated->total(),
                    'has_more'     => $paginated->hasMorePages(),
                ],
            ]);
        }

        // No pagination - return all (backward compatible)
        return response()->json([
            'success' => true,
            'data'    => $query->get(),
        ]);
    }

    /**
     * Submit a new institution (pending approval).
     */
    public function store(Request $request)
    {
        $request->validate([
            'nku'  => 'required|string|max:255',
            'type' => 'required|string',
            'logo' => 'nullable|image|max:3072',
            'img'  => 'nullable|image|max:5120',
        ]);

        $data = $request->except(['logo', 'img', 'kgAge', 'kgHours']);
        // Map camelCase from Flutter to snake_case
        $data['kg_age']     = $request->input('kgAge', '');
        $data['kg_hours']   = $request->input('kgHours', '');
        $data['approved']   = false; // Always pending
        $data['user_id']    = auth()->id(); // Assign to the actual creator

        // Handle logo file upload
        if ($request->hasFile('logo')) {
            $file = $request->file('logo');
            $filename = 'logos/' . uniqid() . '.png';
 
            $img = Image::read($file)
                ->contain(400, 400)
                ->toPng();

            Storage::disk('public')->put($filename, (string) $img);
            $data['logo'] = $filename;
        }
        
        // Handle institution main image
        if ($request->hasFile('img')) {
            $file = $request->file('img');
            $filename = 'logos/' . uniqid() . '_img.webp';

            $img = Image::read($file)
                ->scale(width: 1200)
                ->toWebp(80);

            Storage::disk('public')->put($filename, (string) $img);
            $data['img'] = $filename;
        }

        $institution = Institution::create($data);

        return response()->json([
            'success' => true,
            'message' => 'داواکارییەکەت نێردرا بۆ ئەدمین.',
            'data'    => $institution,
        ], 201);
    }

    /**
     * Get a single institution.
     */
    public function show(string $id)
    {
        $institution = Institution::findOrFail($id);

        return response()->json([
            'success' => true,
            'data'    => $institution,
        ]);
    }

    /**
     * Update an institution.
     */
    public function update(Request $request, string $id)
    {
        $institution = Institution::findOrFail($id);

        $data = $request->except(['logo', 'img']);
        if (isset($data['kgAge']))     $data['kg_age']     = $data['kgAge'];
        if (isset($data['kgHours']))   $data['kg_hours']   = $data['kgHours'];

        // Handle logo file upload on update
        if ($request->hasFile('logo')) {
            $request->validate(['logo' => 'image|max:3072']);
            $file = $request->file('logo');
            $filename = 'logos/' . uniqid() . '.png';

            $img = Image::read($file)
                ->contain(400, 400)
                ->toPng();

            Storage::disk('public')->put($filename, (string) $img);
            $data['logo'] = $filename;
            
            // Delete old logo if it exists
            if ($institution->logo) {
                Storage::disk('public')->delete($institution->getRawOriginal('logo'));
            }
        }
        
        // Handle main image update
        if ($request->hasFile('img')) {
            $request->validate(['img' => 'image|max:5120']);
            $file = $request->file('img');
            $filename = 'logos/' . uniqid() . '_img.webp';

            $img = Image::read($file)
                ->scale(width: 1200)
                ->toWebp(80);

            Storage::disk('public')->put($filename, (string) $img);
            $data['img'] = $filename;

            // Delete old image if it exists
            if ($institution->img) {
                Storage::disk('public')->delete($institution->getRawOriginal('img'));
            }
        }

        $institution->update($data);

        return response()->json([
            'success' => true,
            'message' => 'زانیارییەکان نوێکرانەوە.',
            'data'    => $institution,
        ]);
    }

    /**
     * Delete an institution.
     */
    public function destroy(string $id)
    {
        $institution = Institution::findOrFail($id);
        $institution->delete();

        return response()->json([
            'success' => true,
            'message' => 'دامەزراوەکە سڕایەوە.',
        ]);
    }

    /**
     * Admin: Get all pending institutions.
     */
    public function adminIndex(Request $request)
    {
        $query = Institution::query();

        $status = $request->get('status', 'pending');
        if ($status === 'pending') {
            $query->where('approved', false);
        } elseif ($status === 'approved') {
            $query->where('approved', true);
        }
        // 'all' returns everything

        $query->latest();

        return response()->json([
            'success' => true,
            'data'    => $query->get(),
            'meta'    => [
                'pending'  => Institution::where('approved', false)->count(),
                'approved' => Institution::where('approved', true)->count(),
                'total'    => Institution::count(),
            ],
        ]);
    }

    /**
     * Admin: Approve or reject an institution.
     */
    public function toggleApproval(string $id)
    {
        $institution = Institution::findOrFail($id);
        $institution->approved = !$institution->approved;
        $institution->save();

        return response()->json([
            'success' => true,
            'data'    => $institution,
            'message' => $institution->approved
                ? 'دامەزراوەکە پاساو کرا.'
                : 'دامەزراوەکە ڕەتکرایەوە.',
        ]);
    }

    /**
     * Admin: Delete any institution.
     */
    public function adminDestroy(string $id)
    {
        $institution = Institution::findOrFail($id);
        $institution->delete();

        return response()->json([
            'success' => true,
            'message' => 'دامەزراوەکە سڕایەوە.',
        ]);
    }

    /**
     * Stats endpoint.
     */
    public function stats()
    {
        $approved = Institution::where('approved', true);

        return response()->json([
            'success' => true,
            'data'    => [
                'total'    => (clone $approved)->count(),
                'gov'      => (clone $approved)->where('type', 'gov')->count(),
                'priv'     => (clone $approved)->where('type', 'priv')->count(),
                'inst5'    => (clone $approved)->where('type', 'inst5')->count(),
                'inst2'    => (clone $approved)->where('type', 'inst2')->count(),
                'school'   => (clone $approved)->where('type', 'school')->count(),
                'kg'       => (clone $approved)->where('type', 'kg')->count(),
                'dc'       => (clone $approved)->where('type', 'dc')->count(),
                'cities'   => (clone $approved)->distinct('city')->count('city'),
                'news'     => \App\Models\News::count(),
                'events'   => \App\Models\Event::count(),
                'teachers' => \App\Models\Teacher::where('is_approved', true)->count(),
                'pending'  => Institution::where('approved', false)->count(),
            ],
        ]);
    }

}

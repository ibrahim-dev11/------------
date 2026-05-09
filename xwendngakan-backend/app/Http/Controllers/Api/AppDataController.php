<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\InstitutionType;
use Illuminate\Http\JsonResponse;

class AppDataController extends Controller
{
    /**
     * Get all active institution types.
     */
    public function institutionTypes(): JsonResponse
    {
        $types = InstitutionType::active()->ordered()->get(['key', 'name', 'name_en', 'name_ar', 'emoji', 'icon']);
        
        return response()->json([
            'success' => true,
            'data'    => $types,
        ]);
    }

    /**
     * Unified app data — single endpoint for types + other static data.
     */
    public function appData(): JsonResponse
    {
        $types = InstitutionType::active()->ordered()->get(['key', 'name', 'name_en', 'name_ar', 'emoji', 'icon']);

        return response()->json([
            'success' => true,
            'data'    => [
                'types' => $types,
            ],
        ]);
    }
}

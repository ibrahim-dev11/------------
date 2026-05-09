<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Event;
use Illuminate\Http\Request;

class EventController extends Controller
{
    public function index(Request $request)
    {
        $limit = $request->query('limit', 20);
        
        $events = Event::where('is_active', true)
            ->orderBy('start_date', 'asc')
            ->paginate($limit);

        return response()->json([
            'success' => true,
            'data' => $events->items(),
            'meta' => [
                'current_page' => $events->currentPage(),
                'last_page' => $events->lastPage(),
                'total' => $events->total(),
            ]
        ]);
    }

    public function show($id)
    {
        $event = Event::where('is_active', true)->find($id);

        if (!$event) {
            return response()->json([
                'success' => false,
                'error' => 'Event not found',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $event,
        ]);
    }
}

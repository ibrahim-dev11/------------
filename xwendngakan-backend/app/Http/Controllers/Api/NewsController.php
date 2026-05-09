<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\News;
use Illuminate\Http\Request;

class NewsController extends Controller
{
    public function index(Request $request)
    {
        $limit = $request->query('limit', 20);
        
        $news = News::where('is_active', true)
            ->orderBy('created_at', 'desc')
            ->paginate($limit);

        return response()->json([
            'success' => true,
            'data' => $news->items(),
            'meta' => [
                'current_page' => $news->currentPage(),
                'last_page' => $news->lastPage(),
                'total' => $news->total(),
            ]
        ]);
    }

    public function show($id)
    {
        $news = News::where('is_active', true)->find($id);

        if (!$news) {
            return response()->json([
                'success' => false,
                'error' => 'News not found',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $news,
        ]);
    }
}

<?php

namespace App\Http\Controllers\Api;

use App\Models\Banner;
use Illuminate\Http\JsonResponse;

class BannerController
{
    public function index(): JsonResponse
    {
        $banners = Banner::where('is_active', true)
            ->orderBy('sort_order')
            ->orderBy('created_at')
            ->get()
            ->map(fn($b) => [
                'id'          => $b->id,
                'title'       => $b->title,
                'subtitle'    => $b->subtitle,
                'tag'         => $b->tag,
                'image_url'   => $b->image_url,
                'color_start' => $b->color_start,
                'color_end'   => $b->color_end,
            ]);

        return response()->json(['data' => $banners]);
    }
}

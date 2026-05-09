<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Institution;
use App\Models\InstitutionRequest;
use App\Models\TeacherRequest;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class UserRequestController extends Controller
{
    /**
     * Get my teacher request.
     */
    public function myTeacherRequest(): JsonResponse
    {
        $request = TeacherRequest::where('user_id', auth()->id())->latest()->first();
        
        return response()->json([
            'success' => true,
            'data'    => $request
        ]);
    }

    /**
     * Store a teacher request.
     */
    public function storeTeacherRequest(Request $request): JsonResponse
    {
        $request->validate([
            'name'    => 'required|string',
            'phone'   => 'required|string',
            'message' => 'nullable|string',
        ]);
        
        $teacherRequest = TeacherRequest::updateOrCreate(
            ['user_id' => auth()->id()],
            [
                'name'    => $request->name,
                'phone'   => $request->phone,
                'message' => $request->message,
                'status'  => 'pending'
            ]
        );
        
        return response()->json([
            'success' => true,
            'message' => 'داواکاریەکەت بە سەرکەوتوویی نێردرا، بە زوترین کات پەیوەندیت پێوە دەکرێت',
            'data'    => $teacherRequest
        ]);
    }

    /**
     * Clear my teacher requests.
     */
    public function clearTeacherRequests(): JsonResponse
    {
        TeacherRequest::where('user_id', auth()->id())->delete();
        
        return response()->json(['success' => true]);
    }

    /**
     * Get my institution request.
     */
    public function myInstitutionRequest(): JsonResponse
    {
        $request = InstitutionRequest::where('user_id', auth()->id())->latest()->first();
        
        return response()->json([
            'success' => true,
            'data'    => $request
        ]);
    }

    /**
     * Get my institution.
     */
    public function myInstitution(): JsonResponse
    {
        $inst = Institution::where('user_id', auth()->id())->first();
        
        return response()->json([
            'success' => true,
            'data'    => $inst
        ]);
    }

    /**
     * Store an institution request.
     */
    public function storeInstitutionRequest(Request $request): JsonResponse
    {
        $request->validate([
            'name'  => 'required',
            'phone' => 'required',
        ]);

        $instReq = InstitutionRequest::updateOrCreate(
            ['user_id' => auth()->id()],
            [
                'name'    => $request->name,
                'phone'   => $request->phone,
                'message' => $request->message,
                'status'  => 'pending'
            ]
        );

        return response()->json([
            'success' => true,
            'message' => 'داواکاریەکەت بە سەرکەوتوویی نێردرا، بە زوترین کات پەیوەندیت پێوە دەکرێت',
            'data'    => $instReq
        ]);
    }

    /**
     * Clear my institution requests.
     */
    public function clearInstitutionRequests(): JsonResponse
    {
        InstitutionRequest::where('user_id', auth()->id())->delete();
        
        return response()->json(['success' => true]);
    }
}

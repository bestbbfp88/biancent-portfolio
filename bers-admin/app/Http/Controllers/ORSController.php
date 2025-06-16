<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Http;

class ORSController extends Controller
{
    public function distanceMatrix(Request $request)
    {
        try {
            $response = Http::withHeaders([
                'Authorization' => config('services.openrouteservice.key'),
                'Content-Type' => 'application/json',
            ])->post('https://api.openrouteservice.org/v2/matrix/driving-car', $request->all());
    
            return response()->json($response->json(), $response->status());
    
        } catch (\Exception $e) {
            return response()->json([
                'error' => 'ORS Request Failed',
                'message' => $e->getMessage()
            ], 500);
        }
    }
}

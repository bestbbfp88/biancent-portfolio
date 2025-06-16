<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Services\FirebaseService;
use Illuminate\Support\Facades\Log;

class mapsController extends Controller
{
    protected $firebase;

    public function __construct(FirebaseService $firebaseService)
    {
        $this->firebase = $firebaseService->getDatabase();
    }

    public function getEmergencies()
    {
        try {
            $emergenciesRef = $this->firebase->getReference('emergencies');
            $usersRef = $this->firebase->getReference('users');
    
            $emergencies = $emergenciesRef->getValue();
            $users = $usersRef->getValue();
    
            $formattedEmergencies = [];
            if ($emergencies) {
                foreach ($emergencies as $key => $emergency) {
                    if (!empty($emergency['live_es_latitude']) && !empty($emergency['live_es_longitude'])) {
                        
                        $userID = $emergency['user_ID'] ?? null;
                        $userDetails = isset($userID, $users[$userID])
                            ? $users[$userID]
                            : ['f_name' => 'Unknown', 'l_name' => 'User', 'user_contact' => 'N/A', 'email' => 'N/A', 'birthdate' => 'N/A'];
    
                        $fullName = trim(($userDetails['f_name'] ?? 'Unknown') . ' ' . ($userDetails['l_name'] ?? ''));
    
                        $formattedEmergencies[] = [
                            'lat' => (float) $emergency['live_es_latitude'],
                            'lng' => (float) $emergency['live_es_longitude'],
                            'location' => $emergency['location'] ?? "Unknown Location",
                            'status' => $emergency['report_Status'] ?? "Unknown Status",
                            'date_time' => $emergency['date_time'] ?? "Unknown Date",
                            'userType' => $emergency['is_User'] ?? "Unknown Type",
                            'emergencyID' => $emergency['report_ID'] ?? "Unknown Emergency ID",
                            'user' => [
                                'id' => $userID,
                                'name' => $fullName,
                                'contact' => $userDetails['user_contact'] ?? 'N/A',
                                'email' => $userDetails['email'] ?? 'N/A',
                                'birthdate' => $userDetails['birthdate'] ?? 'N/A'
                            ]
                        ];
                    }
                }
            }
    
            // ✅ Ensure JSON is properly encoded
            return response()->json($formattedEmergencies, 200, ['Content-Type' => 'application/json'], JSON_UNESCAPED_SLASHES | JSON_PRETTY_PRINT);
        } catch (\Exception $e) {
            return response()->json([
                'error' => 'Failed to fetch emergencies',
                'details' => $e->getMessage()
            ], 500);
        }
    }
    
}

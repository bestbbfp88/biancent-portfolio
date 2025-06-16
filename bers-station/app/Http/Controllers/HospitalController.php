<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Services\FirebaseService;

class HospitalController extends Controller
{
    private $firebase;

    public function __construct(FirebaseService $firebaseService)
    {
        $this->firebase = $firebaseService;
    }

    // Fetch hospitals with "Active" status only
    public function fetchHospitals()
    {
        $hospitals =  $this->firebase->getDatabase()->getReference('hospitals');
        $activeHospitals = [];

        if ($hospitals) {
            foreach ($hospitals as $id => $hospital) {
                if (isset($hospital['hospital_status']) && $hospital['hospital_status'] === "Active") {
                    $activeHospitals[$id] = $hospital;
                }
            }
        }

        return response()->json($activeHospitals);
    }

    // Add a new hospital with default status "Active"
    public function addHospital(Request $request)
    {
        $hospitalData = [
            'name' => $request->name,
            'address' => $request->address,
            'hospital_status' => "Active" // Default status
        ];

        $this->firebase->getDatabase()->getReference('hospitals')->push($hospitalData);
        return response()->json(['message' => 'Hospital added successfully']);
    }

    // Update hospital details (name & address)
    public function updateHospital(Request $request, $id)
    {
        $this->firebase->getDatabase()->getReference("hospitals/{$id}")->update([
            'name' => $request->name,
            'address' => $request->address
        ]);

        return response()->json(['message' => 'Hospital updated successfully']);
    }

    // Archive hospital (set status to "Archived")
    public function archiveHospital($id)
    {
        $this->firebase->getDatabase()->getReference("hospitals/{$id}")->update([
            'hospital_status' => "Archived"
        ]);

        return response()->json(['message' => 'Hospital archived successfully']);
    }
}

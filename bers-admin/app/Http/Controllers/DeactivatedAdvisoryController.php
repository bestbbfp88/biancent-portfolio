<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Services\FirebaseService;

class DeactivatedAdvisoryController extends Controller
{
    protected $database;

    public function __construct(FirebaseService $firebaseService)
    {
        $this->database = $firebaseService->getDatabase();
    }

    // ✅ Fetch all deactivated advisories
    public function index()
    {
        $advisoryRef = $this->database->getReference('advisories');
        $advisorySnapshot = $advisoryRef->getValue();

        $deactivatedAdvisory = [];

        if ($advisorySnapshot) {
            foreach ($advisorySnapshot as $key => $advisory) {
                if (isset($advisory['advisory_status']) && $advisory['advisory_status'] === 'Archived') {
                    $advisory['id'] = $key; // Store Firebase key as ID
                    $deactivatedAdvisory[] = $advisory;
                }
            }
        }

        return response()->json($deactivatedAdvisory);
    }

    public function activate(Request $request, $id)
    {
        try {
            // Reference to the advisory in the advisories collection
            $advisoryRef = $this->database->getReference("advisories/{$id}");
    
            // Check if the advisory exists
            if (!$advisoryRef->getSnapshot()->exists()) {
                return response()->json(['message' => 'Advisory not found'], 404);
            }
    
            // Update advisory status to 'Active'
            $advisoryRef->update([
                'advisory_status' => 'Active'
            ]);
    
            return response()->json(['message' => 'Advisory activated successfully']);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Error activating advisory', 'error' => $e->getMessage()], 500);
        }
    }
    
}

<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Services\FirebaseService;

class ActiveAdvisoryController extends Controller
{
    protected $database;

    public function __construct(FirebaseService $firebaseService)
    {
        $this->database = $firebaseService->getDatabase();
        $this->storage = $firebaseService->getStorage();
        $this->firebaseProjectId = env('FIREBASE_STORAGE_BUCKET');
    }

        public function index()
        {
            try {
                $advisoriesRef = $this->database->getReference('advisories')->getValue();
        
                if (!$advisoriesRef) {
                    return response()->json(['error' => 'No active advisories found.'], 404);
                }
        
                $activeAdvisories = [];
                foreach ($advisoriesRef as $key => $advisory) {
                    if (isset($advisory['advisory_status']) && $advisory['advisory_status'] === "Active") {
                        $activeAdvisories[] = array_merge(['id' => $key], $advisory);
                    }
                }
        
                if (empty($activeAdvisories)) {
                    return response()->json(['error' => 'No active advisories found.'], 404);
                }
        
                return response()->json(['advisories' => $activeAdvisories], 200);
        
            } catch (\Throwable $e) {
                return response()->json(['error' => 'Failed to fetch advisories: ' . $e->getMessage()], 500);
            }
        }
    

    /**
     * Fetch all active advisories from Firebase.
     */
    public function fetchActiveAdvisories()
    {
        try {
            $advisoriesRef = $this->database->getReference('advisories')->getValue();
    
            if (!$advisoriesRef) {
                return response()->json(['error' => 'No active advisories found.'], 404);
            }

            $activeAdvisories = [];
            foreach ($advisoriesRef as $key => $advisory) {
                if (isset($advisory['advisory_status']) && $advisory['advisory_status'] === "Active") {
                    $activeAdvisories[] = array_merge(['id' => $key], $advisory);
                }
            }

            if (empty($activeAdvisories)) {
                return response()->json(['error' => 'No active advisories found.'], 404);
            }

            return response()->json(['advisories' => $activeAdvisories], 200);
        } catch (\Exception $e) {
            return response()->json(['error' => 'Failed to fetch advisories: ' . $e->getMessage()], 500);
        }
    }

    /**
     * Stream real-time new advisories (SSE - Server Sent Events).
     */
    public function listenForNewAdvisories()
    {
        return response()->stream(function () {
            $advisoriesRef = $this->database->getReference('advisories');
            $advisoriesRef->orderByKey()->limitToLast(1)->on('child_added', function ($snapshot) {
                echo "data: " . json_encode($snapshot->getValue()) . "\n\n";
                ob_flush();
                flush();
            });
        }, 200, [
            'Content-Type'  => 'text/event-stream',
            'Cache-Control' => 'no-cache',
            'Connection'    => 'keep-alive',
        ]);
    }

    /**
     * Archive an advisory.
     */

     public function archive(Request $request, $id)
     {
         try {
             // Reference to the advisory in the advisories collection
             $ref = $this->database->getReference("advisories/{$id}");
     
             // Check if the advisory exists
             if (!$ref->getSnapshot()->exists()) {
                 return response()->json(['message' => 'Advisory not found'], 404);
             }
     
             // Update advisory_status to 'Archived' in the advisories collection
             $ref->update([
                 'advisory_status' => 'Archived'
             ]);
     
             return response()->json(['message' => 'Advisory archived successfully']);
         } catch (\Exception $e) {
             return response()->json(['message' => 'Server error', 'error' => $e->getMessage()], 500);
         }
     }     

     

    public function update(Request $request, $id)
    {
        try {
            // Validate request
            $request->validate([
                'creator' => 'required|string|max:255',
                'headline' => 'required|string|max:255',
                'message' => 'required|string',
            ]);

            // Reference the advisory in Firebase
            $ref = $this->database->getReference("advisories/{$id}");

            // Check if advisory exists
            $advisory = $ref->getValue();
            if (!$advisory) {
                return response()->json(['message' => 'Advisory not found'], 404);
            }

            // Prepare updated data
            $updatedData = [
                'creator' => $request->input('creator'),
                'headline' => $request->input('headline'),
                'message' => $request->input('message'),
                'updated_at' => now()->toDateTimeString(),
            ];

            if ($request->hasFile('image')) {
                $updatedData['image_url'] = $this->uploadToFirebaseStorage($request->file('image'), 'advisories/images');
            }

            // ✅ Upload File (if exists)
            if ($request->hasFile('file')) {
                $updatedData['file_url'] = $this->uploadToFirebaseStorage($request->file('file'), 'advisories/files');
            }

          
            // Update advisory in Firebase
            $ref->update($updatedData);

            return response()->json(['message' => 'Advisory updated successfully', 'data' => $updatedData]);
        } catch (\Exception $e) {
            return response()->json(['message' => 'Server error', 'error' => $e->getMessage()], 500);
        }
    }

    
}

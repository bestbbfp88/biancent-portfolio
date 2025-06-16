<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Services\FirebaseService;
use Illuminate\Support\Facades\Validator;

class CreateAdvisoryController extends Controller
{
    protected $database;
    protected $storage;
    protected $firebaseProjectId;

    public function __construct(FirebaseService $firebaseService)
    {
        $this->database = $firebaseService->getDatabase();
        $this->storage = $firebaseService->getStorage();
        $this->firebaseProjectId = env('FIREBASE_STORAGE_BUCKET'); // Ensure it's set in .env
    }

    public function store(Request $request)
    {
        try {
            // ✅ Validate the request
            $validatedData = $request->validate([
                'creator'  => 'required|string|max:255',
                'headline' => 'required|string|max:255',
                'message'  => 'required|string',
                'image'    => 'nullable|image|mimes:jpeg,png,jpg,gif,svg|max:2048',
                'file'     => 'nullable|mimes:pdf,doc,docx,txt|max:5120',
            ]);

            if (!$request->hasFile('image') && !$request->hasFile('file')) {
                return response()->json(['error' => 'Please upload at least an image or a document.'], 400);
            }

            // ✅ Prepare Advisory Data
            $advisoryData = [
                'creator'    => $validatedData['creator'],
                'headline'   => $validatedData['headline'],
                'message'    => $validatedData['message'],
                'advisory_status' => 'Active',
                'timestamp'  => now()->timestamp,
                'created_at' => now()->toDateTimeString(),
            ];

            // ✅ Upload Image (if exists)
            if ($request->hasFile('image')) {
                $advisoryData['image_url'] = $this->uploadToFirebaseStorage($request->file('image'), 'advisories/images');
            }

            // ✅ Upload File (if exists)
            if ($request->hasFile('file')) {
                $advisoryData['file_url'] = $this->uploadToFirebaseStorage($request->file('file'), 'advisories/files');
            }

            // ✅ Store Advisory Data in Firebase Realtime Database
            $this->database->getReference('advisories')->push($advisoryData);

            return response()->json([
                'message' => 'Advisory Created Successfully',
                'created_at' => $advisoryData['created_at'],
                'image_url' => $advisoryData['image_url'] ?? null,
                'file_url' => $advisoryData['file_url'] ?? null
            ], 200);

        } catch (\Exception $e) {
            return response()->json(['error' => 'An error occurred: ' . $e->getMessage()], 500);
        }
    }

    /**
     * ✅ Upload File to Firebase Storage and Return Public URL
     */
    private function uploadToFirebaseStorage($file, $folder)
    {
        try {
            $fileName = $folder . '/' . time() . '_' . $file->getClientOriginalName();
            $bucket = $this->storage->getBucket();
    
            // ✅ Debug: Check if the bucket is correctly retrieved
            if (!$bucket) {
                throw new \Exception("Firebase Storage Bucket is not available.");
            }
    
            // ✅ Debug: Log the upload attempt
            \Log::info("Uploading to Firebase: " . $fileName);
    
            // ✅ Upload File to Firebase Storage
            $bucket->upload(file_get_contents($file), [
                'name' => $fileName
            ]);
    
            // ✅ Check if the file exists after upload
            $object = $bucket->object($fileName);
            if (!$object->exists()) {
                throw new \Exception("File upload failed: " . $fileName);
            }
    
            // ✅ Generate and Return Permanent Public URL
            $url = "https://firebasestorage.googleapis.com/v0/b/{$this->firebaseProjectId}/o/" . urlencode($fileName) . "?alt=media";
    
            // ✅ Debug: Log the generated URL
            \Log::info("Firebase URL: " . $url);
    
            return $url;
    
        } catch (\Exception $e) {
            \Log::error("Firebase Storage Error: " . $e->getMessage());
            return null;
        }
    }
    
}

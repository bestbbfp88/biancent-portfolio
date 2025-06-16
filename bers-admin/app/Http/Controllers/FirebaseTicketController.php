<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Services\FirebaseService;

class FirebaseTicketController extends Controller
{
    protected $database;

    public function __construct(FirebaseService $firebaseService)
    {
        $this->database = $firebaseService->getDatabase();
    }

    public function store(Request $request)
    {
        // ✅ Validate request
        $validated = $request->validate([
            'description' => 'required|string|max:255',
            'dateTime' => 'required|date',
            'userName' => 'required|string|max:100',
            'userContact' => 'nullable|string|max:20',
            'userEmail' => 'nullable|email|max:100',
            'notes' => 'nullable|string',
            'emergency_ID' => 'required|string' 
        ]);
    
        // ✅ Reference to Firebase Firestore - Create Ticket
        $newTicketRef = $this->database->getReference('tickets')->push($validated);
        $ticketId = $newTicketRef->getKey(); // ✅ Get Ticket ID
    
        // ✅ Update Emergency with Ticket ID
        $this->database->getReference('emergencies/' . $validated['emergency_id'])
            ->update([
                'ticket_id' => $ticketId, // ✅ Add Ticket ID to emergency
                'report_Status' => 'Ongoing' // ✅ Update status to "Ongoing"
            ]);
    
        return response()->json([
            'success' => true,
            'message' => 'Ticket created and emergency updated successfully!',
            'ticket_id' => $ticketId
        ]);
    }
    
}

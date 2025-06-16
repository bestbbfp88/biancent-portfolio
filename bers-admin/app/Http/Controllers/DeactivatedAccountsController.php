<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Services\FirebaseService;

class DeactivatedAccountsController extends Controller
{
    protected $database;

    public function __construct(FirebaseService $firebaseService)
    {
        $this->database = $firebaseService->getDatabase();
    }

    /**
     * Get all deactivated users (where user_status = "Archived")
     */
    public function index()
    {
        $usersRef = $this->database->getReference('users');
        $usersSnapshot = $usersRef->getValue();

        $deactivatedUsers = [];

        if ($usersSnapshot) {
            foreach ($usersSnapshot as $key => $user) {
                if (isset($user['user_status']) && $user['user_status'] === 'Archived') {
                    $user['id'] = $key; // Store Firebase key as ID
                    $deactivatedUsers[] = $user;
                }
            }
        }

        return response()->json($deactivatedUsers);
    }


    public function listenForNewArchivedUsers()
    {
        return response()->stream(function () {
            $archiveUsersRef = $this->database->getReference('users');
            $archiveUsersRef->orderByKey()->limitToLast(1)->on('child_added', function ($snapshot) {
                echo "event: NewArchivedUser\n"; // Custom event type
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
     * Activate a user by updating their status to "Active"
     */
    public function activate(Request $request, $id)
{
    try {
        // Reference to the users collection
        $userRef = $this->database->getReference("users/{$id}");

        // Check if the user exists in the users collection
        if (!$userRef->getSnapshot()->exists()) {
            return response()->json(['message' => 'User not found'], 404);
        }

        // Update the user status to Active in the users collection
        $userRef->update([
            'user_status' => 'Active'
        ]);

        return response()->json(['message' => 'User activated successfully']);
    } catch (\Exception $e) {
        return response()->json(['message' => 'Error activating user', 'error' => $e->getMessage()], 500);
    }
}

}

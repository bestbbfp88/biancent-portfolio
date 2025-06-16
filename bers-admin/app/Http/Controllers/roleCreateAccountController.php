<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Services\FirebaseService;
use Kreait\Firebase\Exception\Auth\FailedToSendPasswordResetLink;

class roleCreateAccountController extends Controller
{
    protected $firebaseService;
    protected $auth;

    public function __construct(FirebaseService $firebaseService)
    {
        $this->firebaseService = $firebaseService;
        $this->auth = $firebaseService->getAuth();
    }

    /**
     * ✅ Create User by Admin (Firebase Auth + RTDB)
     */
    public function createUserByAdmin(Request $request)
{
    $createdByUid = session('firebase_user.uid');

    // ✅ Validate Input
    $request->validate([
        'email' => 'required|email',
        'phone' => 'required|string',
        'role' => 'required|string',
        'responder_type' => 'nullable|string', // ✅ Only for Emergency Responders
        'lgu_station_id' => 'nullable|string', // ✅ Only for LGU Responders
        'address' => 'nullable|string', // ✅ For Emergency Responder Station
        'station_type' => 'nullable|string', // ✅ For Emergency Responder Station
        'latitude' => 'nullable|string', // ✅ For Emergency Responder Station
        'longitude' => 'nullable|string', // ✅ For Emergency Responder Station
        // ✅ Require f_name & l_name for all roles EXCEPT Emergency Responder Station
        'f_name' => $request->role === "Emergency Responder Station" ? 'nullable' : 'required|string',
        'l_name' => $request->role === "Emergency Responder Station" ? 'nullable' : 'required|string',
        // ✅ Require station_name for Emergency Responder Station
        'station_name' => $request->role === "Emergency Responder Station" ? 'required|string' : 'nullable',
    ]);

    try {
        $auth = $this->firebaseService->getAuth();
        $database = $this->firebaseService->getDatabase();

        // ✅ Check if email already exists in Firebase RTDB (users collection)
        $usersRef = $database->getReference("users")->getValue();

        try {
            $auth->getUserByEmail($request->email);
            $userExists = true;
        } catch (\Kreait\Firebase\Exception\Auth\UserNotFound $e) {
            // ✅ User not found, continue creating the user
            $userExists = false;
        }

        if ($userExists) {
            return response()->json([
                'success' => false,
                'message' => 'Email already exists.'
            ], 400);
        }

        // ✅ Create User in Firebase Authentication
        $userProperties = [
            'email' => $request->email,
            'emailVerified' => false,
            'displayName' => $request->role === "Emergency Responder Station" 
                ? $request->station_name 
                : ($request->f_name . ' ' . $request->l_name),
            'disabled' => false,
        ];

        $createdUser = $auth->createUser($userProperties);
        $uid = $createdUser->uid;

        // ✅ Initialize station ID variable
        $stationId = null;

        // ✅ If role is "Emergency Responder Station", generate station entry first
        if ($request->role === "Emergency Responder Station") {
            // ✅ Generate a unique key for the emergency responder station
            $stationRef = $database->getReference("emergency_responder_station")->push();
            $stationId = $stationRef->getKey(); // Get the generated unique ID

            // ✅ Prepare station data
            $stationData = [
                'station_name' => $request->station_name,
                'station_type' => $request->station_type,
                'address' => $request->address,
                'latitude' => $request->latitude,
                'longitude' => $request->longitude,
                'created_at' => now()->toDateTimeString(),
            ];

            // ✅ Store station data in Firebase RTDB
            $stationRef->set($stationData);
        }

        // ✅ Prepare User Data for Firebase RTDB (users collection)
        $userData = [
            'email' => $request->email,
            'user_contact' => $request->phone,
            'user_role' => $request->role,
            'user_status' => 'Active',
            'created_at' => now()->toDateTimeString(),
        ];

        // ✅ If the role is NOT "Emergency Responder Station", add name fields
        if ($request->role !== "Emergency Responder Station") {
            $userData['f_name'] = $request->f_name;
            $userData['l_name'] = $request->l_name;
        }

        if ($request->role == "Emergency Responder Station") {
            $userData['station_id'] = $stationId;
        }

        // ✅ If user is an "Emergency Responder", store responder_type and station_id
        if ($request->role === "Emergency Responder") {
            $userData['responder_type'] = $request->responder_type;
            $userData['created_by'] = $request->lgu_station_id; // ✅ Save LGU station ID for LGU Responders
            $userData['created_by-admin'] = $createdByUid;
        }

        // ✅ Store User Data in Firebase RTDB (users collection)
        $database->getReference("users/{$uid}")->set($userData);

        // ✅ Send Password Reset Email
        try {
            $auth->sendPasswordResetLink($request->email);
        } catch (FailedToSendPasswordResetLink $e) {
            return response()->json([
                'success' => false,
                'message' => 'User created, but failed to send password reset link.'
            ], 500);
        }

        return response()->json([
            'success' => true,
            'message' => 'User created successfully!',
            'user_id' => $uid,
            'station_id' => $stationId,
            'user_data' => $userData,
            'station_data' => $stationId ? $stationData : null
        ], 201);

    } catch (\Exception $e) {
        return response()->json([
            'success' => false,
            'message' => $e->getMessage()
        ], 500);
    }
}


    public function deleteUser(Request $request, $uid)
        {
            try {

                $csrfToken = $request->header('X-CSRF-TOKEN');
                \Log::info("Received CSRF Token: " . $csrfToken);
        
                // ✅ Delete user from Firebase Authentication
                $this->auth->deleteUser($uid);

                return response()->json([
                    'success' => true,
                    'message' => "User deleted from Firebase Authentication."
                ], 200);
            } catch (UserNotFound $e) {
                return response()->json([
                    'success' => false,
                    'message' => "User not found in Firebase Authentication."
                ], 404);
            } catch (\Exception $e) {
                return response()->json([
                    'success' => false,
                    'message' => "Error deleting user: " . $e->getMessage()
                ], 500);
            }
        }
    


    /**
     * ✅ Fetch LGU Responder Stations (Only Emergency Responder Stations)
     */
    public function getLGUResponderStations()
    {
        try {
            $database = $this->firebaseService->getDatabase();
            $usersRef = $database->getReference('users')->getValue();

            $lguStations = [];

            if ($usersRef) {
                foreach ($usersRef as $uid => $userData) {
                    if (isset($userData['user_role']) && $userData['user_role'] === "Emergency Responder Station") {
                        $lguStations[] = [
                            'id' => $uid,
                            'fullname' => $userData['fullname'],
                        ];
                    }
                }
            }

            return response()->json([
                'success' => true,
                'lgu_stations' => $lguStations
            ]);

        } catch (\Exception $e) {
            return response()->json([
                'success' => false,
                'message' => $e->getMessage()
            ], 500);
        }
    }


    public function disableUser($uid){
    try {
        $auth = $this->firebaseService->getAuth();

        // ✅ Disable the user in Firebase Auth
        $auth->updateUser($uid, ['disabled' => true]);

        return response()->json([
            'success' => true,
            'message' => 'User successfully disabled in Firebase Auth'
        ], 200);

    } catch (UserNotFound $e) {
        return response()->json([
            'success' => false,
            'message' => "User not found: {$e->getMessage()}"
        ], 404);
    } catch (\Exception $e) {
        return response()->json([
            'success' => false,
            'message' => "Error disabling user: {$e->getMessage()}"
        ], 500);
    }
}

public function activateUser($uid){
    try {
        $auth = $this->firebaseService->getAuth();

        // ✅ Activate (Enable) the user in Firebase Auth
        $auth->updateUser($uid, ['disabled' => false]);

        return response()->json([
            'success' => true,
            'message' => 'User successfully activated in Firebase Auth'
        ], 200);

    } catch (\Kreait\Firebase\Exception\Auth\UserNotFound $e) {
        return response()->json([
            'success' => false,
            'message' => "User not found: {$e->getMessage()}"
        ], 404);
    } catch (\Exception $e) {
        return response()->json([
            'success' => false,
            'message' => "Error activating user: {$e->getMessage()}"
        ], 500);
    }
}

public function updateUserEmail(Request $request, $uid)
{
    \Log::info("📨 updateUserEmail() called for UID: {$uid}");

    $request->validate([
        'email' => 'required|email',
    ]);

    \Log::info("✅ Email validated: " . $request->email);

    try {
        $auth = app('firebase.auth');

        \Log::info("🔐 Attempting to update Firebase Auth email for UID: {$uid}");

        // ✅ Try to update email in Firebase Auth
        $auth->updateUser($uid, [
            'email' => $request->email,
        ]);

        \Log::info("✅ Email updated successfully for UID: {$uid}");

        return response()->json([
            'success' => true,
            'message' => 'Email updated successfully in Firebase Auth.',
        ]);

    } catch (\Kreait\Firebase\Exception\Auth\EmailExists $e) {
        \Log::warning("⚠️ Email already in use: " . $request->email);

        return response()->json([
            'success' => false,
            'message' => 'The email is already in use by another account.',
        ], 409);

    } catch (\Kreait\Firebase\Exception\Auth\UserNotFound $e) {
        \Log::error("❌ User not found for UID: {$uid}");

        return response()->json([
            'success' => false,
            'message' => 'User not found in Firebase Authentication.',
        ], 404);

    } catch (\Kreait\Firebase\Exception\InvalidArgument $e) {
        \Log::error("❌ Invalid email format: " . $request->email);

        return response()->json([
            'success' => false,
            'message' => 'Invalid email format.',
        ], 422);

    } catch (\Throwable $e) {
        \Log::error("🔥 Unexpected error updating email for UID {$uid}: " . $e->getMessage());

        return response()->json([
            'success' => false,
            'message' => 'An unexpected error occurred: ' . $e->getMessage(),
        ], 500);
    }
}

}



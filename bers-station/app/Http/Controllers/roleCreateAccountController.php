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

    public function createUserByAdmin(Request $request)
    {
        $createdByUid = session('firebase_user.uid');

        // ✅ Validate Input
        $request->validate([
            'f_name' => 'required|string',
            'l_name' => 'required|string',
            'email' => 'required|email',
            'user_contact' => 'required|string',
            'user_role' => 'required|string',
            'responder_type' => 'required|string',
            'user_status' => 'required|string',
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

            // ✅ Prepare User Data for Firebase RTDB (users collection)
            $userData = [
                'f_name'       => $request->f_name,
                'l_name'       => $request->l_name,
                'email'        => $request->email,
                'user_contact' => $request->user_contact,
                'user_role'    => $request->user_role,
                'user_status'  => 'Pending',
                'responder_type' => $request->responder_type,
                'created_by' => session('firebase_user.uid'),
                'created_at'   => now()->toDateTimeString(),
            ];

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
                'user_data' => $userData,
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
    $request->validate([
        'email' => 'required|email',
    ]);

    try {
        $auth = app('firebase.auth');

        // ✅ Try to update email in Firebase Auth
        $auth->updateUser($uid, [
            'email' => $request->email,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Email updated successfully in Firebase Auth.',
        ]);

    } catch (EmailExists $e) {
        // ⚠️ Email already used by another account
        return response()->json([
            'success' => false,
            'message' => 'The email is already in use by another account.',
        ], 409);

    } catch (UserNotFound $e) {
        // ❌ User not found
        return response()->json([
            'success' => false,
            'message' => 'User not found in Firebase Authentication.',
        ], 404);

    } catch (InvalidArgument $e) {
        // ❌ Invalid email format
        return response()->json([
            'success' => false,
            'message' => 'Invalid email format.',
        ], 422);

    } catch (\Throwable $e) {
        // 🔥 Unexpected errors
        return response()->json([
            'success' => false,
            'message' => 'An unexpected error occurred: ' . $e->getMessage(),
        ], 500);
    }
}

}



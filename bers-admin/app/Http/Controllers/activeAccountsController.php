<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Services\FirebaseService;
use Illuminate\Support\Facades\Log;
use Kreait\Firebase\Exception\Auth\UserNotFound;

class ActiveAccountsController extends Controller
{
    protected $firebaseService;

    public function __construct(FirebaseService $firebaseService)
    {
        $this->firebaseService = $firebaseService;
    }

    public function sendPasswordReset($user_email)
    {
        $auth = $this->firebaseService->getAuth();

        try {
            // Check if the user exists
            $user = $auth->getUserByEmail($user_email);
            
            // Firebase sends the password reset email directly
            $auth->sendPasswordResetLink($user_email);

            \Log::info("Firebase password reset email sent to: " . $user_email);

            return response()->json([
                'success' => true, 
                'message' => 'Password reset email sent successfully.'
            ]);
        } catch (UserNotFound $e) {
            return response()->json([
                'success' => false, 
                'message' => 'User not found.'
            ]);
        } catch (\Exception $e) {
            \Log::error("Error sending Firebase password reset email: " . $e->getMessage());
            return response()->json([
                'success' => false, 
                'message' => 'Internal server error.'
            ], 500);
        }
    }
    
}

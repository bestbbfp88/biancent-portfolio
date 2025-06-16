<?php

namespace App\Http\Controllers;

use Illuminate\Support\Facades\Log;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Session;
use Kreait\Firebase\Exception\Auth\UserNotFound;
use App\Services\FirebaseService;
use Kreait\Firebase\Factory;

class AdminAuthController extends Controller
{
    protected $auth;
    protected $database;
    
    public function __construct(FirebaseService $firebase)
    {
        $this->auth = $firebase->getAuth();
        $this->database = $firebase->getDatabase(); 
    }
    
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required'
        ]);
    
        try {
            // Authenticate user with Firebase
            $user = $this->auth->signInWithEmailAndPassword($request->email, $request->password);
            $firebaseUser = $this->auth->getUserByEmail($request->email);
    
            if (!$firebaseUser->emailVerified) {
                return redirect()->back()->withErrors(['error' => 'Please verify your email first'])->withInput();
            }
    
            // Retrieve user data from Firebase Realtime Database
            $uid = $firebaseUser->uid;
            $userRef = $this->database->getReference('users/' . $uid)->getValue();
    
            // Check if user exists and has one of the allowed roles
            if ($userRef && isset($userRef['user_role'])) {
                $allowedRoles = ['Admin', 'Communicator', 'Resource Manager'];
    
                if (in_array($userRef['user_role'], $allowedRoles)) {
                    // Store Firebase user UID and role explicitly in session
                    Session::put('firebase_user', [
                        'uid' => $uid,
                        'email' => $firebaseUser->email,
                        'role' => $userRef['user_role']
                    ]);
    
                    return redirect('/admin/dashboard')->with('message', 'Login successful!');
                } else {
                    return redirect()->back()
                        ->withErrors(['error' => 'Unauthorized access.'])
                        ->withInput();
                }
            } else {
                return redirect()->back()
                    ->withErrors(['error' => 'User not found or role missing.'])
                    ->withInput();
            }
    
        } catch (\Exception $e) {
            return redirect()->back()
                ->withErrors(['error' => 'Invalid email or password.'])
                ->withInput();
        }
    }
    
    
    

    public function register(Request $request)
    {
        try {
            $userEmail = $request->input('email');
    
            try {
                $this->auth->getUserByEmail($userEmail);
                return response()->json([
                    'errors' => ['email' => ['The email address is already in use.']]
                ], 422);
            } catch (UserNotFound $e) {
                // Check if admin already exists in database
                $admins = $this->database->getReference('users')
                    ->orderByChild('user_role')
                    ->equalTo('Admin')
                    ->getValue();
    
                if (!empty($admins)) {
                    return redirect()->back()->withErrors(['modal_error' => 'Admin already exists.'])->withInput()->with('clear_errors', true);
                } else {
                    // Validate form inputs
                    $request->validate([
                        'fname' => 'required|string|max:255',
                        'lname' => 'required|string|max:255',
                        'birthdate' => 'required|date',
                        'address' => 'required|string|max:255',
                        'gender' => 'required|in:Male,Female,Other',
                        'user_contact' => 'required|digits_between:10,15',
                        'email' => 'required|email',
                        'password' => 'required|min:6|confirmed',
                    ]);
    
                    // Create user in Firebase Authentication
                    $newUser = $this->auth->createUserWithEmailAndPassword($userEmail, $request->password);
                    $firebaseUser = $this->auth->getUserByEmail($userEmail);
                    $uid = $firebaseUser->uid;
    
                    // Send email verification link
                    $this->auth->sendEmailVerificationLink($userEmail);
    
                    // Store user details in Firebase Realtime Database
                    $databaseData = [
                        'f_name' => $request->fname,
                        'l_name' => $request->lname,
                        'birthdate' => $request->birthdate,
                        'address' => $request->address,
                        'gender' => $request->gender,
                        'user_contact' => $request->user_contact,
                        'user_role' => 'Admin',
                        'user_status' => 'Active', // Updated status
                        'email' => $userEmail,
                        'uid' => $uid,
                        'created_at' => now(),
                    ];
    
                    try {
                        $this->database->getReference("users/{$uid}")->set($databaseData);
                    } catch (\Exception $e) {
                        Log::error('Error inserting data into Realtime Database:', [
                            'error' => $e->getMessage(),
                            'trace' => $e->getTraceAsString()
                        ]);
                    }
    
                    return redirect('/')->with('success', 'Registration successful! Please verify your email before logging in.');
                }
            }
        } catch (\Exception $e) {
            Log::error("Error during registration: " . $e->getMessage());
            return back()->withErrors(['error' => 'Something went wrong. Please try again later.']);
        }
    }

    public function resendVerificationEmail(Request $request)
{
    try {
        $userEmail = $request->input('email');
        $firebaseUser = $this->auth->getUserByEmail($userEmail);

        if ($firebaseUser->emailVerified) {
            return redirect('/login')->with('message', 'Your email is already verified.');
        }

        $this->auth->sendEmailVerificationLink($userEmail);
        return back()->with('message', 'Verification email resent successfully.');
    } catch (\Exception $e) {
        return back()->withErrors(['error' => 'Failed to resend verification email.']);
    }
}

    

    public function logout()
    {
        Session::forget('firebase_user');
        return redirect('/')->with('message', 'Logged out successfully.');
    }

    public function dashboard(Request $request)
    {
        $firebaseUser = Session::get('firebase_user');

        if (!$firebaseUser) {
            return redirect('/')->withErrors(['error' => 'Unauthorized. Please login first.']);
        }

        $firebase = (new Factory)
                 ->withServiceAccount(config('firebase.projects.app.credentials'));

        $auth = $firebase->createAuth();

        $customTokenString = $auth->createCustomToken($firebaseUser['uid'])->toString();

        return view('landingpage', [
            'firebaseCustomToken' => $customTokenString,
            'firebaseUser' => $firebaseUser
        ]);
    }

    
}

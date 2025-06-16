<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Kreait\Firebase\Factory;
use Kreait\Firebase\Auth;
use Illuminate\Support\Facades\Session;
use Illuminate\Support\Facades\Log;
use Symfony\Component\HttpFoundation\Response;

class FirebaseAuthMiddleware
{
    protected $auth;

    public function __construct()
    {
        $factory = (new Factory)
        ->withServiceAccount(config('firebase.projects.app.credentials')); // Ensure correct path
        $this->auth = $factory->createAuth();
    }

    public function handle(Request $request, Closure $next): Response
    {
        if (!Session::has('firebase_user')) {
            return redirect('/')->withErrors(['error' => 'You must be logged in to access this page.']);
        }

        try {
            // Retrieve the Firebase user from session
            $firebaseUser = Session::get('firebase_user');

            // Check if the user actually exists in Firebase
            $user = $this->auth->getUser($firebaseUser['uid']);

            return $next($request);
        } catch (\Exception $e) {
            Log::error("Firebase Auth Middleware Error: " . $e->getMessage());
            Session::forget('firebase_user'); // Clear invalid session
            return redirect('/')->withErrors(['error' => 'Authentication failed. Please log in again.']);
        }
    }
}

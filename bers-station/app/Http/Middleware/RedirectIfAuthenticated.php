<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Kreait\Firebase\Factory;
use Kreait\Firebase\Auth;
use Illuminate\Support\Facades\Session;
use Symfony\Component\HttpFoundation\Response;

class RedirectIfAuthenticated
{
    protected $auth;

    public function __construct()
    {
        $factory = (new Factory)
        ->withServiceAccount(config('firebase.projects.app.credentials'));
        $this->auth = $factory->createAuth();
    }

    public function handle(Request $request, Closure $next): Response
    {
        // Check if user session exists
        if (Session::has('firebase_user')) {
            try {
                // Check if the user actually exists in Firebase
                $firebaseUser = Session::get('firebase_user');
                $user = $this->auth->getUser($firebaseUser['uid']);

                // If authenticated, redirect to dashboard
                return redirect('/emergency-responder-station/dashboard');
            } catch (\Exception $e) {
                // If session exists but Firebase authentication fails, clear session and proceed
                Session::forget('firebase_user');
            }
        }

        return $next($request);
    }
}

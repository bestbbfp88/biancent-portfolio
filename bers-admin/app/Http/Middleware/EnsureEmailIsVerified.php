<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Kreait\Firebase\Factory;
use Kreait\Firebase\Auth;
use Illuminate\Support\Facades\Session;
use Illuminate\Support\Facades\Log;
use Symfony\Component\HttpFoundation\Response;

class EnsureEmailIsVerified
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
        if (!Session::has('firebase_user')) {
            return redirect('/login')->withErrors(['error' => 'Please log in first.']);
        }

        try {
            $firebaseUser = $this->auth->getUserByEmail(Session::get('firebase_user')['email']);

            if (!$firebaseUser->emailVerified) {
                return redirect('/email/verify')->with('error', 'Please verify your email before accessing this page.');
            }

            return $next($request);
        } catch (\Exception $e) {
            Log::error("Firebase Email Verification Middleware Error: " . $e->getMessage());
            return redirect('/login')->withErrors(['error' => 'Unable to verify email. Please try again.']);
        }
    }
}

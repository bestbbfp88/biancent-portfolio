<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Services\FirebaseService;

class RouteViewController extends Controller
{
    protected $firebase;

    public function __construct(FirebaseService $firebase)
    {
        $this->firebase = $firebase;
    }


    public function showLogin(){

        $database = $this->firebase->getDatabase();

        $admins = $database->getReference('users')
            ->orderByChild('user_role')
            ->equalTo('Admin')
            ->getValue();

        return view('auth.login', ['adminExists' => !empty($admins)]);
    }

}

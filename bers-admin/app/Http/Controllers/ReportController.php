<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class ReportController extends Controller
{
    public function index()
    {
        $user = Auth::user(); // Get currently signed-in user
        return view('modals.generate_report', compact('user'));
    }
}

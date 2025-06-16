<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\RouteViewController;
use App\Http\Controllers\AdminAuthController;
use App\Http\Controllers\mapsController;
use App\Http\Controllers\FirebaseTicketController;
use App\Http\Middleware\FirebaseAuthMiddleware;
use App\Http\Middleware\EnsureEmailIsVerified;
use App\Http\Middleware\RedirectIfAuthenticated;
use Illuminate\Http\Request;
use Kreait\Firebase\Exception\Auth\UserNotFound;
use Kreait\Firebase\Auth;
use App\Services\FirebaseService;
use App\Http\Controllers\roleCreateAccountController;
use App\Http\Controllers\activeAccountsController;
use App\Http\Controllers\DeactivatedAccountsController;
use App\Http\Controllers\CreateAdvisoryController;
use App\Http\Controllers\ActiveAdvisoryController;
use App\Http\Controllers\DeactivatedAdvisoryController;
use App\Http\Controllers\HospitalController;
use Kreait\Firebase\Factory;
use App\Http\Controllers\ReportController;


// Prevent authenticated users from accessing login & register pages
Route::middleware([RedirectIfAuthenticated::class])->group(function () {
    Route::get('/', [RouteViewController::class, 'showLogin']);
    Route::view('/register', 'auth.registration')->name('register');

    // Authentication Routes
    Route::post('/admin/register', [AdminAuthController::class, 'register']);
    Route::post('/admin/login', [AdminAuthController::class, 'login']);
});

// Authentication Routes (Logout should be accessible only when logged in)
Route::post('/admin/logout', [AdminAuthController::class, 'logout'])->middleware([FirebaseAuthMiddleware::class]);
Route::post('/admin/resend-verification', [AdminAuthController::class, 'resendVerificationEmail'])
    ->name('admin.resend.verification')
    ->middleware([FirebaseAuthMiddleware::class]);

// AJAX Email Validation Route
Route::post('/check-email', function (Request $request, FirebaseService $firebaseService) {
    $auth = $firebaseService->getAuth();

    try {
        $auth->getUserByEmail($request->email);
        return response()->json(['valid' => false]); // Email is already taken
    } catch (UserNotFound $e) {
        return response()->json(['valid' => true]); // Email is available
    } catch (\Exception $e) {
        return response()->json(['valid' => false, 'error' => 'Internal error'], 500);
    }
});



// Firebase API Routes (For emergencies & tickets)
Route::get('/api/emergencies', [mapsController::class, 'getEmergencies']);
Route::post('/firebase-tickets', [FirebaseTicketController::class, 'store']);


Route::middleware([FirebaseAuthMiddleware::class, EnsureEmailIsVerified::class])->group(function () {
    Route::get('/admin/dashboard', [AdminAuthController::class, 'dashboard'])->name('admin.dashboard');
});



Route::post('/api/admin/create-user', [roleCreateAccountController::class, 'createUserByAdmin']);
Route::get('/get-lgu-stations', [roleCreateAccountController::class, 'getLGUResponderStations']);
Route::delete('/delete-user/{uid}', [roleCreateAccountController::class, 'deleteUser']);

Route::post('/admin/password-reset/{id}', [activeAccountsController::class, 'sendPasswordReset']);
Route::get('/deactivated-users', [DeactivatedAccountsController::class, 'index']);
Route::put('/activate-user/{id}', [DeactivatedAccountsController::class, 'activate']);



Route::delete('/reject-user/{uid}', function ($uid, FirebaseService $firebaseService) {
    try {
        $auth = $firebaseService->getAuth();
        $database = $firebaseService->getDatabase();

        // Delete user from Firebase Authentication
        $auth->deleteUser($uid);

        // Remove user from Realtime Database
        $database->getReference("users/{$uid}")->remove();

        return response()->json(['success' => true, 'message' => 'User rejected and deleted successfully.']);
    } catch (UserNotFound $e) {
        Log::error("User Not Found: " . $e->getMessage());
        return response()->json(['success' => false, 'message' => 'User not found.'], 404);
    } catch (\Exception $e) {
        Log::error("Error deleting user: " . $e->getMessage());
        return response()->json(['success' => false, 'message' => 'Error deleting user.'], 500);
    }
});


Route::post('/advisory/create', [CreateAdvisoryController::class, 'store'])->name('advisory.store');
Route::get('/advisories/active', [ActiveAdvisoryController::class, 'index'])->name('advisories.active');
Route::post('/advisories/archive/{id}', [ActiveAdvisoryController::class, 'archive'])->name('advisories.archive');
Route::get('/advisories/active', [ActiveAdvisoryController::class, 'fetchActiveAdvisories']);
Route::get('/advisories/stream', [ActiveAdvisoryController::class, 'listenForNewAdvisories']);
Route::post('/advisories/archive/{id}', [ActiveAdvisoryController::class, 'archive'])->name('advisories.archive');
Route::post('/advisories/update/{id}', [ActiveAdvisoryController::class, 'update'])->name('advisories.update');
Route::get('/deactivated-advisories', [DeactivatedAdvisoryController::class, 'index'])->name('advisories.index');
Route::put('/activate-advisory/{id}', [DeactivatedAdvisoryController::class, 'activate'])->name('advisories.activate');


Route::get('/api/hospitals', [HospitalController::class, 'fetchHospitals']);
Route::post('/api/hospitals', [HospitalController::class, 'addHospital']);
Route::put('/api/hospitals/{id}', [HospitalController::class, 'updateHospital']);
Route::put('/api/hospitals/{id}/archive', [HospitalController::class, 'archiveHospital']);

// Other Static Pages
Route::view('/about', 'about');
Route::view('/contact', 'contact');


Route::post('/admin/disable-user/{uid}', [roleCreateAccountController::class, 'disableUser']);
Route::post('/admin/activate-user/{uid}', [roleCreateAccountController::class, 'activateUser']);

Route::post('/update-user-email/{uid}', [roleCreateAccountController::class, 'updateUserEmail']);


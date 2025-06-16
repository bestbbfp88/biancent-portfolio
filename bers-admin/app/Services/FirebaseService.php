<?php

namespace App\Services;

use Kreait\Firebase\Factory;
use Kreait\Firebase\Contract\Auth;
use Kreait\Firebase\Contract\Database;
use Kreait\Firebase\Contract\Storage;

class FirebaseService
{
    private Auth $auth;
    private Database $database;
    private Storage $storage;

    public function __construct()
    {
        $databaseUrl = "https://database-4b12a-default-rtdb.firebaseio.com";
        $storageBucket = env('FIREBASE_STORAGE_BUCKET', 'database-4b12a.appspot.com');  


        $factory = (new Factory)
            ->withServiceAccount(config('firebase.projects.app.credentials'))
            ->withDatabaseUri($databaseUrl)
            ->withDefaultStorageBucket($storageBucket);

        $this->auth = $factory->createAuth();
        $this->database = $factory->createDatabase();
        $this->storage = $factory->createStorage();
    }

    public function getAuth(): Auth
    {
        return $this->auth;
    }

    public function getDatabase(): Database
    {
        return $this->database;
    }

    public function getStorage(): Storage
    {
        return $this->storage;
    }
}

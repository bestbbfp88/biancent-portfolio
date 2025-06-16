package com.example.bers_responder

import android.app.Application
import android.app.NotificationChannel
import android.app.NotificationManager
import android.os.Build

class MyApplication : Application() {

    companion object {
        const val CHANNEL_ID = "emergency_tracking"
    }

    override fun onCreate() {
        super.onCreate()

        // Create notification channel for Android 8.0+
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val channel = NotificationChannel(
                CHANNEL_ID,
                "Emergency Tracking",
                NotificationManager.IMPORTANCE_LOW
            )
            channel.description = "Tracking location in the background for emergency response."

            // Register the channel with the system
            val manager = getSystemService(NotificationManager::class.java)
            manager?.createNotificationChannel(channel)
        }
    }
}

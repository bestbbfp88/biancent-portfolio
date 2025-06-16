package com.example.bers_responder

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class BootBroadcastReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        // Log the boot event for debugging
        Log.d("BootBroadcastReceiver", "Boot event received")

        // Create an intent to communicate with Flutter (via Dart)
        val serviceIntent = Intent(context, MainActivity::class.java)
        serviceIntent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)

        // Start the MainActivity or any other Flutter activity to trigger the background service
        context?.startActivity(serviceIntent)
    }
}

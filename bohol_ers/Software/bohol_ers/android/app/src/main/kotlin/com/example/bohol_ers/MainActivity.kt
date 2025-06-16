package com.example.bohol_ers

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "call_channel"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Use the correct binaryMessenger from the Flutter engine
        MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                if (call.method == "makeCall") {
                    val phoneNumber = call.argument<String>("number")

                    // Create the call intent with the 'CALL_PHONE' action
                    val intent = Intent(Intent.ACTION_CALL).apply {
                        data = Uri.parse("tel:$phoneNumber")
                    }

                    try {
                        startActivity(intent)  // Initiates the phone call
                        result.success(null)  // Send success back to Flutter
                    } catch (e: SecurityException) {
                        result.error("PERMISSION_DENIED", "Permission to make calls is denied", null)
                    }
                } else {
                    result.notImplemented()  // Respond if the method is not implemented
                }
            }
    }
}

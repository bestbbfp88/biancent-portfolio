package com.example.application247;

import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

public class Profile extends AppCompatActivity {
TextView full_name, userID;
ImageView logoutButton, personal_info, request_btn;
String uid;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_profile);

        SharedPreferences preferences = getSharedPreferences("user_preferences", MODE_PRIVATE);
        uid = preferences.getString("userID", "");

        full_name = findViewById(R.id.name_profile);
        userID = findViewById(R.id.number);

        DatabaseReference databaseReference = FirebaseDatabase.getInstance().getReference();
        String userPath = "userInfo/" + uid;
        // Create a ValueEventListener

// Add the ValueEventListener to the specific child path
        databaseReference.child(userPath).addListenerForSingleValueEvent(new ValueEventListener() {
            @Override
            public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
                // Handle data for a single event
                if (dataSnapshot.exists()) {
                    userInfo UserInfo = dataSnapshot.getValue(userInfo.class);
                    if (UserInfo != null) {
                        String userFname = UserInfo.getUserFname();
                        String userLname = UserInfo.getUserLname();
                        String userContact = UserInfo.getUserContact();

                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                full_name.setText(userFname + " " + userLname);
                                userID.setText(userContact);
                            }
                        });
                    }
                }
            }

            @Override
            public void onCancelled(@NonNull DatabaseError databaseError) {
                // Handle errors
                Log.e("FirebaseRead", "Error reading data: " + databaseError.getMessage());
            }
        });



        personal_info = findViewById(R.id.personal_inf);
        personal_info.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(Profile.this, info_edit.class);
                startActivity(intent);
            }
        });
        ImageView back_btn;
        back_btn = findViewById(R.id.back_white);
        back_btn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(Profile.this, Options.class);
                startActivity(intent);
            }
        });

        request_btn = findViewById(R.id.req_logs);
        request_btn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(Profile.this, reqlogs.class);
                startActivity(intent);
            }
        });


        logoutButton = findViewById(R.id.logout);
        logoutButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // Perform logout actions
                logout();
                Toast.makeText(Profile.this, "Successfully logged Out", Toast.LENGTH_SHORT).show();
                // Redirect to the login screen
                Intent intent = new Intent(Profile.this, Login.class);
                startActivity(intent);
                finish(); // Close the current activity
            }
        });
    }



    private void logout() {
        // Clear user session or credentials, depending on your authentication mechanism
        // For example, if you are using SharedPreferences for storing user credentials:
        SharedPreferences preferences = getSharedPreferences("user_preferences", MODE_PRIVATE);
        SharedPreferences.Editor editor = preferences.edit();
        editor.clear();
        editor.apply();
        finish();
    }

    }

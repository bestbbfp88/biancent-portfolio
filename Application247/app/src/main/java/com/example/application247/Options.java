package com.example.application247;

import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

public class Options extends AppCompatActivity {

    TextView full_name;
    String userContact;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_opt);
        Button request_btn = findViewById(R.id.request_btn);
        ImageView imageView2 = findViewById(R.id.pic);
        full_name = findViewById(R.id.name_profile);
        SharedPreferences preferences = getSharedPreferences("user_preferences", MODE_PRIVATE);
        String userID = preferences.getString("userID", "");

        DatabaseReference databaseReference = FirebaseDatabase.getInstance().getReference();
        String userPath = "userInfo/" + userID;
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
                        userContact = UserInfo.getUserContact();

                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                full_name.setText(userFname + " " + userLname);
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


// Add the ValueEventListener for real-time updates



        request_btn.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                // Handle click for imageView1
                // For example, start an activity or perform an action
                Intent intent = new Intent(Options.this, Request01.class);
                intent.putExtra("full_name", full_name.getText().toString());
                startActivity(intent);
            }
        });

        imageView2.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                // Handle click for imageView1
                // For example, start an activity or perform an action
                Intent intent = new Intent(Options.this, Profile.class);
                intent.putExtra("userMobile", userContact);
                intent.putExtra("full_name", full_name.getText().toString());
                startActivity(intent);
            }
        });
    }
}
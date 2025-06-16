package com.example.application247;


import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.ImageButton;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;
import com.google.firebase.firestore.DocumentReference;
import com.google.firebase.firestore.FirebaseFirestore;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.HashMap;
import java.util.Map;

public class Request01 extends AppCompatActivity {

    private static final int LOCATION_PERMISSION_REQUEST_CODE = 1;
    String  location, reqtype, status, dateTime, locationString;
    FirebaseFirestore fStore;
    FirebaseAuth auth;
    String userID;
    TextView full_name;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_request01);


        full_name = findViewById(R.id.name_profile);
        String name = getIntent().getStringExtra("full_name");
        full_name.setText(name);

        auth = FirebaseAuth.getInstance();
        fStore = FirebaseFirestore.getInstance();

        FirebaseUser currentUser = auth.getCurrentUser();
        if (currentUser == null) {
            // Redirect to login if user is not authenticated
            startActivity(new Intent(this, Login.class));
            finish();
            return;
        }

        userID = currentUser.getUid();

        ImageButton imageView1 = findViewById(R.id.ambulance);
        ImageButton imageView2 = findViewById(R.id.fire);
        ImageButton imageView3 = findViewById(R.id.police);
        ImageView imageView4 = findViewById(R.id.pic);


        imageView4.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                Intent intent = new Intent(getApplicationContext(), Profile.class);
                startActivity(intent);
            }
        });


        imageView1.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                setAmbulance();
                Intent intent = new Intent(getApplicationContext(), request_success.class);
                startActivity(intent);
            }
        });

        imageView2.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                setFire();
                Intent intent = new Intent(getApplicationContext(), request_success.class);
                startActivity(intent);
            }
        });

        imageView3.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                setPolice();
                Intent intent = new Intent(getApplicationContext(), request_success.class);
                startActivity(intent);
            }
        });

    }

    private void setPolice() {


        // Manually set the values for location and reqtype
        location = "Baclayon"; // Set location to "baclayon"
        reqtype = "Police"; // Set reqtype to "ambulance"
        status = "Pending";
        dateTime = getCurrentDateTime();


        // Fetch fname and pnum from Firestore
        DatabaseReference databaseReference = FirebaseDatabase.getInstance().getReference();
        String userPath = "userInfo/" + userID;
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

                        String full_name = userFname +" "+ userLname;
                        DocumentReference userReference3 = fStore.collection("users").document(userID);

                        // Create a new document under the user's logs sub-collection
                        // Use a unique identifier for each log entry (for example, timestamp)
                        Map<String, Object> logData = new HashMap<>();
                        logData.put("name", full_name);
                        logData.put("pnum", userContact);
                        logData.put("location", location);
                        logData.put("reqtype", reqtype);
                        logData.put("Status", status);
                        logData.put("datetime", dateTime);

                        // Add a new document to the user's logs sub-collection
                        fStore.collection("users").document(userID)
                                .collection("user_logs")
                                .add(logData)
                                .addOnSuccessListener(documentReference -> {
                                    // Log data added successfully
                                    // Do any additional tasks if needed
                                })
                                .addOnFailureListener(e -> {
                                    // Handle failure to add log data
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


        }

    private void setFire() {
        // Manually set the values for location and reqtype

        location = "baclayon";// Set location to static
        reqtype = "Fire Truck"; // Set reqtype to "ambulance"
        status = "Pending";
        dateTime = getCurrentDateTime();
       // location = locationString.toString();

        // Fetch fname and pnum from Firestore
        DatabaseReference databaseReference = FirebaseDatabase.getInstance().getReference();
        String userPath = "userInfo/" + userID;
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

                        String full_name = userFname +" "+ userLname;
                        DocumentReference userReference3 = fStore.collection("users").document(userID);

                        // Create a new document under the user's logs sub-collection
                        // Use a unique identifier for each log entry (for example, timestamp)
                        Map<String, Object> logData = new HashMap<>();
                        logData.put("name", full_name);
                        logData.put("pnum", userContact);
                        logData.put("location", location);
                        logData.put("reqtype", reqtype);
                        logData.put("Status", status);
                        logData.put("datetime", dateTime);


                        // Add a new document to the user's logs sub-collection
                        fStore.collection("users").document(userID)
                                .collection("user_logs")
                                .add(logData)
                                .addOnSuccessListener(documentReference -> {
                                    // Log data added successfully
                                    // Do any additional tasks if needed
                                })
                                .addOnFailureListener(e -> {
                                    // Handle failure to add log data
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


    }

    private void setAmbulance() {
        // Manually set the values for location and reqtype
        location = "baclayon"; // Set location to "baclayon"
        reqtype = "Ambulance"; // Set reqtype to "ambulance"
        status = "Pending";
        dateTime = getCurrentDateTime();

        // Fetch fname and pnum from Firestore
        DatabaseReference databaseReference = FirebaseDatabase.getInstance().getReference();
        String userPath = "userInfo/" + userID;
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

                        String full_name = userFname +" "+ userLname;
                        DocumentReference userReference3 = fStore.collection("users").document(userID);

                        // Create a new document under the user's logs sub-collection
                        // Use a unique identifier for each log entry (for example, timestamp)
                        Map<String, Object> logData = new HashMap<>();
                        logData.put("name", full_name);
                        logData.put("pnum", userContact);
                        logData.put("location", location);
                        logData.put("reqtype", reqtype);
                        logData.put("Status", status);
                        logData.put("datetime", dateTime);

                        // Add a new document to the user's logs sub-collection
                        fStore.collection("users").document(userID)
                                .collection("user_logs")
                                .add(logData)
                                .addOnSuccessListener(documentReference -> {
                                    // Log data added successfully
                                    // Do any additional tasks if needed
                                })
                                .addOnFailureListener(e -> {
                                    // Handle failure to add log data
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


    }
        public String getCurrentDateTime() {
            // Get the current date and time
            LocalDateTime currentDateTime = LocalDateTime.now();

            // Format the date and time using a DateTimeFormatter
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
            String formattedDateTime = currentDateTime.format(formatter);

            // Return the formatted date and time
            return formattedDateTime;
        }





}



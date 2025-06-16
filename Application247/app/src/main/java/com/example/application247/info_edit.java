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

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

public class info_edit extends AppCompatActivity {

    public static final String TAG = "TAG";
    TextView editTextfname, editTextlname, editTextpnum, editTextaddress, editTextemail, Edit_btn;
    Button saveChanges, cancel_btn;
    ImageView back_btn;
    FirebaseAuth mAuth;
    DatabaseReference databaseReference = FirebaseDatabase.getInstance().getReference();
    String uid;


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_info_edit);

        SharedPreferences preferences = getSharedPreferences("user_preferences", MODE_PRIVATE);
        uid = preferences.getString("userID", "");

        editTextemail = findViewById(R.id.email_add);
        editTextfname = findViewById(R.id.fname);
        editTextlname = findViewById(R.id.lname);
        editTextpnum = findViewById(R.id.phone);
        editTextaddress = findViewById(R.id.address);
        saveChanges = findViewById(R.id.save);

        // Retrieve user data and populate EditText fields
        retrieveUserData();
        saveChanges = findViewById(R.id.save);
        cancel_btn = findViewById(R.id.cancel);
        back_btn = findViewById(R.id.back_btn);
        Edit_btn = findViewById(R.id.Edit);

        back_btn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(info_edit.this, Profile.class);
                startActivity(intent);
            }
        });
        Edit_btn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                saveChanges.setVisibility(View.VISIBLE);
                cancel_btn.setVisibility(View.VISIBLE);
                enableEdit();
            }
        });

        cancel_btn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                saveChanges.setVisibility(View.GONE);
                cancel_btn.setVisibility(View.GONE);
                disableEdit();
            }
        });


        saveChanges.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                    DatabaseReference databaseReference = FirebaseDatabase.getInstance().getReference();
                    String userPath = "userInfo/" + uid;
                    userInfo updatedUser = new userInfo();
                    updatedUser.setUserFname(editTextfname.getText().toString().trim());
                    updatedUser.setUserLname(editTextlname.getText().toString().trim());
                    updatedUser.setUserAddress(editTextaddress.getText().toString().trim());
                    updatedUser.setUserContact(editTextpnum.getText().toString().trim());
                    updatedUser.setUserEmail(editTextemail.getText().toString().trim());

                    databaseReference.child(userPath).setValue(updatedUser);

                // Hide save and cancel buttons, and disable editing
                saveChanges.setVisibility(View.GONE);
                cancel_btn.setVisibility(View.GONE);
                disableEdit();
            }
        });

    }



    private void disableEdit(){
        editTextemail.setEnabled(false);
        editTextfname.setEnabled(false);
        editTextlname.setEnabled(false);
        editTextpnum.setEnabled(false);
        editTextaddress.setEnabled(false);
    }
    private void enableEdit(){
        editTextemail.setEnabled(true);
        editTextfname.setEnabled(true);
        editTextlname.setEnabled(true);
        editTextaddress.setEnabled(true);
    }


    private void retrieveUserData() {
        disableEdit();
        DatabaseReference databaseReference = FirebaseDatabase.getInstance().getReference();
        String userPath = "userInfo/" + uid;
        databaseReference.child(userPath).addListenerForSingleValueEvent(new ValueEventListener(){
            @Override
            public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
                if (dataSnapshot.exists()) {
                    userInfo UserInfo = dataSnapshot.getValue(userInfo.class);
                    if (UserInfo != null) {
                        String userFname = UserInfo.getUserFname();
                        String userLname = UserInfo.getUserLname();
                        String userAddress = UserInfo.getUserAddress();
                        String userContact = UserInfo.getUserContact();
                        String userEmail =UserInfo.getUserEmail();

                        // Update UI with the retrieved data
                        editTextfname.setText(userFname);
                        editTextlname.setText(userLname);
                        editTextaddress.setText(userAddress);
                        editTextpnum.setText(userContact);
                        editTextemail.setText(userEmail);
                    }

                }
            }

            @Override
            public void onCancelled(@NonNull DatabaseError databaseError) {
                Log.e("FirebaseRead", "Error reading data: " + databaseError.getMessage());
            }
        });
    }
}








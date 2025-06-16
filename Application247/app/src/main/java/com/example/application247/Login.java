package com.example.application247;

import static android.content.ContentValues.TAG;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.view.Window;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ProgressBar;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseException;
import com.google.firebase.FirebaseTooManyRequestsException;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthInvalidCredentialsException;
import com.google.firebase.auth.FirebaseAuthMissingActivityForRecaptchaException;
import com.google.firebase.auth.PhoneAuthCredential;
import com.google.firebase.auth.PhoneAuthOptions;
import com.google.firebase.auth.PhoneAuthProvider;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

import java.util.concurrent.TimeUnit;

public class Login extends AppCompatActivity {
private Button signup_btn;
private ImageButton back_btn;
private String countryCode = "+63";
private String mVerificationId;
private boolean otpSent = false;
private FirebaseAuth mAuth;
final DatabaseReference usersRef = FirebaseDatabase.getInstance().getReference().child("userInfo");


    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        setContentView(R.layout.activity_login);
        mAuth = FirebaseAuth.getInstance();
        FirebaseApp.initializeApp(this);

         signup_btn = findViewById(R.id.btn_signup);
        signup_btn.setOnClickListener(new View.OnClickListener() {
            public void onClick(View v) {
                Intent intent = new Intent(getApplicationContext(), Sign_Up.class);
                startActivity(intent);
                finish();
            }
        });


        back_btn = findViewById(R.id.backbutton);
        back_btn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(getApplicationContext(), MainActivity.class);
                startActivity(intent);
                finish();
            }
        });



        final EditText editphone = findViewById(R.id.editContact);
        final ProgressBar progressBar = findViewById(R.id.progressbar);

        final Button lgn_btn = findViewById(R.id.lgn_btn);
        lgn_btn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {

                if (editphone.getText().toString().trim().isEmpty()) {
                    Toast.makeText(Login.this, "Enter Mobile Number", Toast.LENGTH_SHORT).show();
                    return;
                } else {
                    if (editphone.getText().toString().trim().length() < 10) {
                        Toast.makeText(Login.this, "Enter Valid Mobile Number", Toast.LENGTH_SHORT).show();
                    } else {
                        String mobile = "+63" + editphone.getText().toString();
                        usersRef.orderByChild("userContact").equalTo(mobile).addListenerForSingleValueEvent(new ValueEventListener() {
                            @Override
                            public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
                                if (dataSnapshot.exists()) {
                                    // User_android exists, proceed with phone number verification
                                    progressBar.setVisibility(View.VISIBLE);
                                    lgn_btn.setVisibility(View.INVISIBLE);

                                    final String getMobile = editphone.getText().toString();
                                    PhoneAuthOptions options = PhoneAuthOptions.newBuilder(mAuth)
                                            .setPhoneNumber(countryCode + "" + editphone.getText().toString()) // Phone number to verify
                                            .setTimeout(60L, TimeUnit.SECONDS) // Timeout duration
                                            .setActivity(Login.this)
                                            .setCallbacks(new PhoneAuthProvider.OnVerificationStateChangedCallbacks() {
                                                @Override
                                                public void onVerificationCompleted(@NonNull PhoneAuthCredential phoneAuthCredential) {
                                                    progressBar.setVisibility(View.GONE);
                                                    lgn_btn.setVisibility(View.VISIBLE);
                                                    Log.d(TAG, "onVerificationCompleted:" + phoneAuthCredential);
                                                }

                                                @Override
                                                public void onVerificationFailed(@NonNull FirebaseException e) {
                                                    progressBar.setVisibility(View.GONE);
                                                    lgn_btn.setVisibility(View.VISIBLE);
                                                    Log.w(TAG, "onVerificationFailed", e);

                                                    if (e instanceof FirebaseAuthInvalidCredentialsException) {
                                                        Toast.makeText(Login.this, "Invalid Credential", Toast.LENGTH_SHORT).show();
                                                        // Invalid request
                                                    } else if (e instanceof FirebaseTooManyRequestsException) {
                                                        // The SMS quota for the project has been exceeded
                                                        Toast.makeText(Login.this, "Too Many Request. Please Try Again Later", Toast.LENGTH_SHORT).show();
                                                    } else if (e instanceof FirebaseAuthMissingActivityForRecaptchaException) {
                                                        // reCAPTCHA verification attempted with null Activity
                                                        Toast.makeText(Login.this, "Missing Activity For Recaptcha Exception", Toast.LENGTH_SHORT).show();
                                                    }
                                                }

                                                @Override
                                                public void onCodeSent(@NonNull String verificationId, @NonNull PhoneAuthProvider.ForceResendingToken forceResendingToken) {
                                                    super.onCodeSent(verificationId, forceResendingToken);
                                                    progressBar.setVisibility(View.GONE);
                                                    lgn_btn.setVisibility(View.VISIBLE);
                                                    mVerificationId = verificationId;
                                                    // Correct order of statements
                                                    Toast.makeText(Login.this, "OTP Sent Successfully", Toast.LENGTH_SHORT).show();
                                                    Intent intent = new Intent(getApplicationContext(), OTP_verification.class);
                                                    intent.putExtra("mobile", editphone.getText().toString());
                                                    intent.putExtra("mVerificationId", mVerificationId.toString());
                                                    startActivity(intent);
                                                    finish();
                                                }
                                            }).build();
                                    PhoneAuthProvider.verifyPhoneNumber(options);

                                } else {
                                    // User_android does not exist, show a message
                                    Toast.makeText(Login.this, "User_android not registered", Toast.LENGTH_SHORT).show();
                                }
                            }

                            @Override
                            public void onCancelled(@NonNull DatabaseError databaseError) {
                                // Handle error
                                Log.e(TAG, "onCancelled", databaseError.toException());
                            }
                        });


                    }

                }
            }
        });
    }
}
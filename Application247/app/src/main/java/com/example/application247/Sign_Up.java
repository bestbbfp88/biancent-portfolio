package com.example.application247;

import static android.content.ContentValues.TAG;

import android.content.Intent;
import android.os.Bundle;
import android.os.CountDownTimer;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;
import android.view.Window;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageButton;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.android.gms.tasks.Task;
import com.google.firebase.FirebaseApp;
import com.google.firebase.FirebaseException;
import com.google.firebase.FirebaseTooManyRequestsException;
import com.google.firebase.auth.AuthResult;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseAuthInvalidCredentialsException;
import com.google.firebase.auth.FirebaseAuthMissingActivityForRecaptchaException;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.auth.PhoneAuthCredential;
import com.google.firebase.auth.PhoneAuthOptions;
import com.google.firebase.auth.PhoneAuthProvider;
import com.google.firebase.database.DataSnapshot;
import com.google.firebase.database.DatabaseError;
import com.google.firebase.database.DatabaseReference;
import com.google.firebase.database.FirebaseDatabase;
import com.google.firebase.database.ValueEventListener;

import java.util.concurrent.TimeUnit;

public class Sign_Up extends AppCompatActivity {

    private EditText fNameval, lNameval, addressval, contactval, OTP_val, resend_OTP, mobileNum;
    private Button CreateAccountbutton, btn_login, OTP_btn, verify_btn, resendButton;
    private ImageButton back_btn;
    private String countryCode = "+63", mVerificationId, mobile;
    private static final long OTP_RESEND_INTERVAL = 60000; // 1 minute in milliseconds
    private TextView Countdown;
    private CountDownTimer countDownTimer;
    FirebaseAuth Sign_mAuth = FirebaseAuth.getInstance(), reSign_mAuth = FirebaseAuth.getInstance();
    final DatabaseReference usersRef = FirebaseDatabase.getInstance().getReference().child("userInfo");
    FirebaseDatabase firebaseDatabase;
    DatabaseReference databaseReference;
    String uid;
    userInfo UserInfo;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        requestWindowFeature(Window.FEATURE_NO_TITLE);
        FirebaseApp.initializeApp(this);
        setContentView(R.layout.activity_sign_up);

        Countdown = findViewById(R.id.countDown);
        resendButton = findViewById(R.id.resend_btn);


// initializing our edittext and button
        fNameval = findViewById(R.id.editFname);
        lNameval = findViewById(R.id.editLname);
        addressval = findViewById(R.id.editAddress);
        contactval = findViewById(R.id.editContact);
        OTP_val = findViewById(R.id.OTP_edit);

        firebaseDatabase = FirebaseDatabase.getInstance();
// below line is used to get reference for our database.
        databaseReference = firebaseDatabase.getReference("userInfo");
        UserInfo = new userInfo();

        OTP_btn = findViewById(R.id.OTP_btn);
        final ProgressBar progressBar = findViewById(R.id.progressbarSign);

        OTP_btn.setOnClickListener(new View.OnClickListener() {

                        @Override
                        public void onClick(View v) {

                            if(contactval.getText().toString().isEmpty()) {
                                Toast.makeText(Sign_Up.this, "Please input Contact Number", Toast.LENGTH_SHORT).show();
                            }else{
                                final EditText editphone = findViewById(R.id.editContact);
                                mobile = countryCode + editphone.getText().toString();
                                usersRef.orderByChild("userContact").equalTo(mobile).addListenerForSingleValueEvent(new ValueEventListener(){
                                    @Override
                                    public void onDataChange(@NonNull DataSnapshot dataSnapshot) {
                                        if (dataSnapshot.exists()) {
                                            Toast.makeText(Sign_Up.this, "Contact Number already registered", Toast.LENGTH_SHORT).show();
                                        }else{
                                            progressBar.setVisibility(View.VISIBLE);
                                            OTP_btn.setVisibility(View.INVISIBLE);
                                            final String getMobile = "+63" + contactval.getText().toString();
                                            PhoneAuthOptions options= PhoneAuthOptions.newBuilder(Sign_mAuth)
                                                    .setPhoneNumber(getMobile.toString())       // Phone number to verify
                                                    .setTimeout(60L, TimeUnit.SECONDS) // Timeout duration
                                                    .setActivity( Sign_Up.this)
                                                    // Activity (for callback binding)
                                                    .setCallbacks(new PhoneAuthProvider.OnVerificationStateChangedCallbacks() {

                                                        @Override
                                                        public void onVerificationCompleted(@NonNull PhoneAuthCredential phoneAuthCredential) {
                                                            Toast.makeText(Sign_Up.this, "TEST", Toast.LENGTH_SHORT).show();
                                                            progressBar.setVisibility(View.GONE);
                                                            OTP_btn.setVisibility(View.VISIBLE);
                                                            Log.d(TAG, "onVerificationCompleted:" + phoneAuthCredential);
                                                        }

                                                        @Override
                                                        public void onVerificationFailed(@NonNull FirebaseException e) {
                                                            progressBar.setVisibility(View.GONE);
                                                            OTP_btn.setVisibility(View.VISIBLE);
                                                            Log.w(TAG, "onVerificationFailed", e);

                                                            if (e instanceof FirebaseAuthInvalidCredentialsException) {
                                                                Toast.makeText(Sign_Up.this, "Invalid Credential", Toast.LENGTH_SHORT).show();
                                                                // Invalid request
                                                            } else if (e instanceof FirebaseTooManyRequestsException) {
                                                                // The SMS quota for the project has been exceeded
                                                                Toast.makeText(Sign_Up.this, "Too Many Request. Please Try Again Later", Toast.LENGTH_SHORT).show();
                                                            } else if (e instanceof FirebaseAuthMissingActivityForRecaptchaException) {
                                                                // reCAPTCHA verification attempted with null Activity
                                                                Toast.makeText(Sign_Up.this, "Missing Activity For Recaptcha Exception", Toast.LENGTH_SHORT).show();
                                                            }
                                                        }

                                                        @Override
                                                        public void onCodeSent(@NonNull String verificationId, @NonNull PhoneAuthProvider.ForceResendingToken forceResendingToken) {
                                                            super.onCodeSent(verificationId, forceResendingToken);
                                                            verify_btn = findViewById(R.id.verify_btn);
                                                            progressBar.setVisibility(View.GONE);
                                                            OTP_btn.setVisibility(View.GONE);
                                                            mVerificationId= verificationId;

                                                            verify_btn.setVisibility(View.VISIBLE);
                                                            // Correct order of statements
                                                            Toast.makeText(Sign_Up.this, "OTP Sent Successfully", Toast.LENGTH_SHORT).show();
                                                            resendButton.setVisibility(View.VISIBLE);
                                                            resendButton.setOnClickListener(new View.OnClickListener() {
                                                                @Override
                                                                public void onClick(View v) {
                                                                    resendButton.setVisibility(View.GONE);
                                                                    // Handle resend button click
                                                                    startTimer();
                                                                    PhoneAuthOptions options = PhoneAuthOptions.newBuilder(reSign_mAuth)
                                                                            .setPhoneNumber(getMobile.toString())       // Phone number to verify
                                                                            .setTimeout(60L, TimeUnit.SECONDS) // Timeout duration
                                                                            .setActivity( Sign_Up.this)
                                                                            // Activity (for callback binding)
                                                                            .setCallbacks(new PhoneAuthProvider.OnVerificationStateChangedCallbacks() {

                                                                                @Override
                                                                                public void onVerificationCompleted(@NonNull PhoneAuthCredential phoneAuthCredential) {
                                                                                    Log.d(TAG, "onVerificationCompleted:" + phoneAuthCredential);
                                                                                }

                                                                                @Override
                                                                                public void onVerificationFailed(@NonNull FirebaseException e) {

                                                                                    Log.w(TAG, "onVerificationFailed", e);
                                                                                    if (e instanceof FirebaseAuthInvalidCredentialsException) {
                                                                                        Toast.makeText(Sign_Up.this, "Invalid Credential", Toast.LENGTH_SHORT).show();
                                                                                        // Invalid request
                                                                                    } else if (e instanceof FirebaseTooManyRequestsException) {
                                                                                        // The SMS quota for the project has been exceeded
                                                                                        Toast.makeText(Sign_Up.this, "Too Many Request. Please Try Again Later", Toast.LENGTH_SHORT).show();
                                                                                    } else if (e instanceof FirebaseAuthMissingActivityForRecaptchaException) {
                                                                                        // reCAPTCHA verification attempted with null Activity
                                                                                        Toast.makeText(Sign_Up.this, "Missing Activity For Recaptcha Exception", Toast.LENGTH_SHORT).show();
                                                                                    }
                                                                                }

                                                                                @Override
                                                                                public void onCodeSent(@NonNull String verificationId, @NonNull PhoneAuthProvider.ForceResendingToken forceResendingToken) {
                                                                                    super.onCodeSent(verificationId, forceResendingToken);
                                                                                    mVerificationId= verificationId;
                                                                                    // Correct order of statements
                                                                                    Toast.makeText(Sign_Up.this, "OTP Sent Successfully", Toast.LENGTH_SHORT).show();

                                                                                }
                                                                            }).build();
                                                                    PhoneAuthProvider.verifyPhoneNumber(options);

                                                                }
                                                            });



                                                            verify_btn.setOnClickListener(new View.OnClickListener() {
                                                                @Override
                                                                public void onClick(View v) {
                                                                    String otp = OTP_val.getText().toString();
                                                                    verifyOTP(otp, mVerificationId);
                                                                }
                                                            });

                                                        }
                                                    }).build();
                                            PhoneAuthProvider.verifyPhoneNumber(options);
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

                        private void startTimer() {
                            countDownTimer = new CountDownTimer(OTP_RESEND_INTERVAL, 1000) {
                                @Override
                                public void onTick(long millisUntilFinished) {
                                    Countdown.setVisibility(View.VISIBLE);
                                    updateTimerText(millisUntilFinished);
                                }

                                @Override
                                public void onFinish() {
                                    Countdown.setVisibility(View.GONE);
                                    resendButton.setVisibility(View.VISIBLE);
                                }
                            }.start();
                        }

                        private void updateTimerText(long millisUntilFinished) {
                            long seconds = millisUntilFinished / 1000;
                            Countdown.setText(getString(R.string.timer_format, seconds));
                        }




                        private void verifyOTP(String otp, String mVerificationId) {
                            if (mVerificationId != null && !mVerificationId.isEmpty()) {
                                PhoneAuthCredential credential =PhoneAuthProvider.getCredential(mVerificationId,otp);
                                signInWithCredential(credential);
                            } else {
                                Toast.makeText(Sign_Up.this, "Error Verification ID", Toast.LENGTH_SHORT).show();
                            }

                        }


                        private void signInWithCredential(PhoneAuthCredential credential) {

                            Sign_mAuth.signInWithCredential(credential)
                                    .addOnCompleteListener(Sign_Up.this, new OnCompleteListener<AuthResult>() {
                                        @Override
                                        public void onComplete(@NonNull Task<AuthResult> task) {

                                            if (task.isSuccessful()) {
                                                // Verification successful, handle the signed-in user
                                                Toast.makeText(Sign_Up.this, "Verification successful", Toast.LENGTH_SHORT).show();
                                                // You can navigate to the next activity or perform other actions
                                                FirebaseUser user = FirebaseAuth.getInstance().getCurrentUser();
                                                // Add the UID to the Realtime Database
                                                uid = user.getUid();
                                                addUidToDatabase(uid);

                                            } else {
                                                // If verification fails, display an error message to the user
                                                Toast.makeText(Sign_Up.this, "Verification failed", Toast.LENGTH_SHORT).show();
                                                // You can also implement retry mechanisms or other error handling here
                                                if (task.getException() instanceof FirebaseAuthInvalidCredentialsException) {
                                                    // The verification code entered was invalid
                                                }
                                            }
                                        }
                                    });
                        }
                    private void addUidToDatabase(String uid) {
                        DatabaseReference databaseReference = FirebaseDatabase.getInstance().getReference();
                        String userPath = "userInfo/" + uid;

                        // Create a new user entry with UID as the key
                        userInfo newUser = new userInfo();
                        databaseReference.child(userPath).setValue(newUser);
                    }

        });

        CreateAccountbutton = findViewById(R.id.btn_create);
        // adding on click listener for our button.
        CreateAccountbutton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // getting text from our edittext fields.
                String userID = uid.toString();
                String fName = fNameval.getText().toString();
                String lName = lNameval.getText().toString();
                String address = addressval.getText().toString();
                String contact = "+63" + contactval.getText().toString();
                // below line is for checking whether the
                // edittext fields are empty or not.
                if(TextUtils.isEmpty(fName) || TextUtils.isEmpty(lName) || TextUtils.isEmpty(address)|| TextUtils.isEmpty(contact)){
                    Toast.makeText(Sign_Up.this, "Fields cannot be empty", Toast.LENGTH_SHORT).show();
                }else{
                    addDatatoFirebase(userID, fName,lName, address, contact);
                }
            }

        });



        btn_login = findViewById(R.id.btn_signup);
        btn_login.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(getApplicationContext(), Login.class);
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




    }

    private static userInfo userInfo = new userInfo();
    private void addDatatoFirebase(String uid, String fName, String lName, String address, String contact) {
        DatabaseReference databaseReference = FirebaseDatabase.getInstance().getReference();
        String userPath = "userInfo/" + uid;
        userInfo updatedUser = new userInfo();
        updatedUser.setUserFname(fName);
        updatedUser.setUserLname(lName);
        updatedUser.setUserAddress(address);
        updatedUser.setUserContact(contact);

        // Update user entry in the Realtime Database
        databaseReference.child(userPath).setValue(updatedUser)
                .addOnSuccessListener(new OnSuccessListener<Void>() {
                    @Override
                    public void onSuccess(Void aVoid) {
                        Toast.makeText(Sign_Up.this, "Account Created Successfully", Toast.LENGTH_SHORT).show();
                        Intent intent = new Intent(getApplicationContext(), Login.class);
                        startActivity(intent);
                        finish();
                    }
                })
                .addOnFailureListener(new OnFailureListener() {
                    @Override
                    public void onFailure(@NonNull Exception e) {
                        Toast.makeText(Sign_Up.this, "Failed to Create Account " + e.getMessage(), Toast.LENGTH_SHORT).show();
                    }
                });
    }



}
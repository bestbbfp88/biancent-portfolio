package com.example.application247;

import static android.content.ContentValues.TAG;

import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.os.CountDownTimer;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.appcompat.app.AppCompatActivity;

import com.google.android.gms.tasks.OnCompleteListener;
import com.google.android.gms.tasks.Task;
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

import java.util.concurrent.TimeUnit;

public class OTP_verification extends AppCompatActivity {

    private EditText inpudecode1, inpudecode2,inpudecode3,inpudecode4,inpudecode5,inpudecode6, editphone_Vr;
    private Button submit_btn;
    private FirebaseAuth mAuth = FirebaseAuth.getInstance();
    private static final long OTP_RESEND_INTERVAL = 60000; // 1 minute in milliseconds
    private TextView Countdown;
    private Button resendButton;
    private CountDownTimer countDownTimer;
    String mVerificationId;
    String countryCode = "+63";
    String userMobile, userID;
    FirebaseUser currentUser = mAuth.getCurrentUser();

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_otp_verification);


        TextView mobileText = findViewById(R.id.mobileText);
        mobileText.setText(String.format(
                countryCode + getIntent().getStringExtra("mobile")
        ));

        userMobile =  mobileText.getText().toString();

        Countdown = findViewById(R.id.Countdown);
        resendButton = findViewById(R.id.resend_btn);
        enableResendButton();
        resendButton.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                // Handle resend button click
                disableResendButton();
                startTimer();
                PhoneAuthOptions options= PhoneAuthOptions.newBuilder(mAuth)
                        .setPhoneNumber(userMobile)       // Phone number to verify
                        .setTimeout(60L, TimeUnit.SECONDS) // Timeout duration
                        .setActivity( OTP_verification.this)
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
                                    Toast.makeText(OTP_verification.this, "Invalid Credential", Toast.LENGTH_SHORT).show();
                                    // Invalid request
                                } else if (e instanceof FirebaseTooManyRequestsException) {
                                    // The SMS quota for the project has been exceeded
                                    Toast.makeText(OTP_verification.this, "Too Many Request. Please Try Again Later", Toast.LENGTH_SHORT).show();
                                } else if (e instanceof FirebaseAuthMissingActivityForRecaptchaException) {
                                    // reCAPTCHA verification attempted with null Activity
                                    Toast.makeText(OTP_verification.this, "Missing Activity For Recaptcha Exception", Toast.LENGTH_SHORT).show();
                                }
                            }

                            @Override
                            public void onCodeSent(@NonNull String verificationId, @NonNull PhoneAuthProvider.ForceResendingToken forceResendingToken) {
                                super.onCodeSent(verificationId, forceResendingToken);
                                mVerificationId= verificationId;
                                // Correct order of statements
                                Toast.makeText(OTP_verification.this, "OTP Sent Successfully", Toast.LENGTH_SHORT).show();

                            }
                        }).build();
                PhoneAuthProvider.verifyPhoneNumber(options);
            }
        });

        inpudecode1 = findViewById(R.id.code1);
        inpudecode2 = findViewById(R.id.code2);
        inpudecode3 = findViewById(R.id.code3);
        inpudecode4 = findViewById(R.id.code4);
        inpudecode5 = findViewById(R.id.code5);
        inpudecode6 = findViewById(R.id.code6);

        setupOTPinputs();
    }
    private void startTimer() {
        countDownTimer = new CountDownTimer(OTP_RESEND_INTERVAL, 1000) {
            @Override
            public void onTick(long millisUntilFinished) {
                updateTimerText(millisUntilFinished);
            }

            @Override
            public void onFinish() {
                enableResendButton();
            }
        }.start();
    }

    private void updateTimerText(long millisUntilFinished) {
        long seconds = millisUntilFinished / 1000;
        Countdown.setText(getString(R.string.timer_format, seconds));
    }

    private void enableResendButton() {
        resendButton.setEnabled(true);
        Countdown.setVisibility(View.GONE);
    }

    private void disableResendButton() {
        resendButton.setEnabled(false);
        Countdown.setVisibility(View.VISIBLE);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        // Cancel the timer to avoid memory leaks
        if (countDownTimer != null) {
            countDownTimer.cancel();
        }
    }


    private void setupOTPinputs(){
        inpudecode1.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                if(!s.toString().trim().isEmpty()){
                    inpudecode2.requestFocus();
                }
            }

            @Override
            public void afterTextChanged(Editable s) {

            }
        });
        inpudecode2.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                if(!s.toString().trim().isEmpty()){
                    inpudecode3.requestFocus();
                }
            }

            @Override
            public void afterTextChanged(Editable s) {

            }
        });
        inpudecode3.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                if(!s.toString().trim().isEmpty()){
                    inpudecode4.requestFocus();
                }
            }

            @Override
            public void afterTextChanged(Editable s) {

            }
        });
        inpudecode4.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                if(!s.toString().trim().isEmpty()){
                    inpudecode5.requestFocus();
                }
            }

            @Override
            public void afterTextChanged(Editable s) {

            }
        });
        inpudecode5.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                if(!s.toString().trim().isEmpty()){
                    inpudecode6.requestFocus();
                }
            }

            @Override
            public void afterTextChanged(Editable s) {

            }
        });
        inpudecode6.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                if (!s.toString().trim().isEmpty()) {
                    // When the last digit is entered, initiate the verification process
                    String otp = inpudecode1.getText().toString() +
                            inpudecode2.getText().toString() +
                            inpudecode3.getText().toString() +
                            inpudecode4.getText().toString() +
                            inpudecode5.getText().toString() +
                            inpudecode6.getText().toString();

                    // Call a method to handle the verification process

                    submit_btn = findViewById(R.id.sumbit_btn);
                    submit_btn.setOnClickListener(new View.OnClickListener() {
                        @Override
                        public void onClick(View v) {
                            verifyOTP(otp);
                        }
                    });
                }
            }

            @Override
            public void afterTextChanged(Editable s) {
            }
        });
    }
    private void verifyOTP(String otp) {

        mVerificationId = getIntent().getStringExtra("mVerificationId");

        if (mVerificationId != null && !mVerificationId.isEmpty()) {
            PhoneAuthCredential credential = PhoneAuthProvider.getCredential(mVerificationId, otp);
            signInWithCredential(credential);

        } else {
            Toast.makeText(OTP_verification.this, "Error Verification ID", Toast.LENGTH_SHORT).show();
        }

    }

    private void signInWithCredential(PhoneAuthCredential credential) {

        mAuth.signInWithCredential(credential)
                .addOnCompleteListener(this, new OnCompleteListener<AuthResult>() {
                    @Override
                    public void onComplete(@NonNull Task<AuthResult> task) {

                        if (task.isSuccessful()) {
                            FirebaseUser currentUser = FirebaseAuth.getInstance().getCurrentUser();

                            SharedPreferences preferences = getSharedPreferences("user_preferences", MODE_PRIVATE);
                            SharedPreferences.Editor editor = preferences.edit();
                            userID = currentUser.getUid();
                            editor.putString("userID", userID);
                            editor.putBoolean("isLoggedIn", true);
                            editor.apply();
                            FirebaseUser user = task.getResult().getUser();
                            Intent intent = new Intent(getApplicationContext(), verification_Success.class);
                            intent.putExtra("userMobile", userMobile);
                            startActivity(intent);
                            finish();
                        } else {
                            // If verification fails, display an error message to the user
                            Toast.makeText(OTP_verification.this, "Verification failed", Toast.LENGTH_SHORT).show();
                            // You can also implement retry mechanisms or other error handling here
                            if (task.getException() instanceof FirebaseAuthInvalidCredentialsException) {
                                // The verification code entered was invalid
                            }
                        }
                    }
                });
    }
}
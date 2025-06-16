package com.example.application247;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.Button;

import androidx.appcompat.app.AppCompatActivity;

public class verification_Success extends AppCompatActivity {
    Button continue_btn;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_verification_success);
        continue_btn = findViewById(R.id.continue_btn);
        continue_btn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                String userMobile = getIntent().getStringExtra("userMobile");
                Intent intent = new Intent(getApplicationContext(), Options.class);
                intent.putExtra("userMobile", userMobile);
                startActivity(intent);
                finish();
            }
        });
    }
}
package com.example.application247;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.ImageView;

import androidx.appcompat.app.AppCompatActivity;

public class request_success extends AppCompatActivity {

    ImageView newreq_btn, mainpage_btn;
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_request_success);

        newreq_btn = findViewById(R.id.newRequest_btn);
        newreq_btn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(request_success.this, Request01.class);
                startActivity(intent);
            }
        });

        mainpage_btn = findViewById(R.id.mainpage_btn);
        mainpage_btn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(request_success.this, Options.class);
                startActivity(intent);
            }
        });


    }
}
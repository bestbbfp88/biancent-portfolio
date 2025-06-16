package com.example.application247;

import android.content.Intent;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.widget.ImageView;
import android.widget.ProgressBar;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.firestore.DocumentChange;
import com.google.firebase.firestore.EventListener;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.FirebaseFirestoreException;
import com.google.firebase.firestore.QuerySnapshot;

import java.util.ArrayList;

public class reqlogs extends AppCompatActivity {

    RecyclerView recyclerView;
    ArrayList<User_android> userArrayList;
    MyAdapter myAdapter;
    FirebaseFirestore db;
    FirebaseAuth auth;
    ProgressBar progressBar;
    String userID;
    ImageView back_btn;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_reqlogs);

        auth = FirebaseAuth.getInstance();
        db = FirebaseFirestore.getInstance();

        FirebaseUser currentUser = auth.getCurrentUser();
        if (currentUser == null) {
            // Redirect to login if user is not authenticated
            startActivity(new Intent(this, Login.class));
            finish();
            return;
        }

        userID = currentUser.getUid();

        progressBar = new ProgressBar(this);
        progressBar.setVisibility(View.VISIBLE);



        recyclerView = findViewById(R.id.recyclerView);
        recyclerView.setHasFixedSize(true);
        recyclerView.setLayoutManager(new LinearLayoutManager(this));

        userArrayList = new ArrayList<User_android>();
        myAdapter = new MyAdapter(reqlogs.this,userArrayList);

        recyclerView.setAdapter(myAdapter);

        EventChangeListener();

        back_btn = findViewById(R.id.back_rqst_btn);
        back_btn.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                Intent intent = new Intent(getApplicationContext(), Profile.class);
                startActivity(intent);
                finish();
            }
        });

    }

    private void EventChangeListener() {
        db.collection("users").document(userID)
                .collection("user_logs")
                .addSnapshotListener(new EventListener<QuerySnapshot>() {
                    @Override
                    public void onEvent(@Nullable QuerySnapshot value, @Nullable FirebaseFirestoreException error) {

                        if(error != null){

                            if(progressBar.isShown())
                                progressBar.setVisibility(View.GONE);
                            Log.e("Firestore error",error.getMessage());
                            return;
                        }

                        for(DocumentChange dc : value.getDocumentChanges()){

                            if(dc.getType() == DocumentChange.Type.ADDED){

                                userArrayList.add(dc.getDocument().toObject(User_android.class));

                            }

                            myAdapter.notifyDataSetChanged();
                            if(progressBar.isShown())
                                progressBar.setVisibility(View.GONE);

                        }

                    }
                });
    }


}

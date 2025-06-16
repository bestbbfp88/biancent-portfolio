package com.example.application247;

import android.content.Context;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.RecyclerView;

import com.google.android.gms.tasks.OnFailureListener;
import com.google.android.gms.tasks.OnSuccessListener;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseUser;
import com.google.firebase.firestore.CollectionReference;
import com.google.firebase.firestore.FirebaseFirestore;
import com.google.firebase.firestore.QueryDocumentSnapshot;
import com.google.firebase.firestore.QuerySnapshot;
import com.google.firebase.firestore.WriteBatch;

import java.util.ArrayList;



public class MyAdapter extends RecyclerView.Adapter<MyAdapter.MyViewHolder> {

    Context context;
    ArrayList<User_android> userArrayList;



    public MyAdapter(Context context, ArrayList<User_android> userArrayList) {
        this.context = context;
        this.userArrayList = userArrayList;
    }



    @NonNull
    @Override
    public MyViewHolder onCreateViewHolder(@NonNull ViewGroup parent, int viewType) {

        View v = LayoutInflater.from(context).inflate(R.layout.item,parent, false);

        return new MyViewHolder(v);

    }


    @Override
    public void onBindViewHolder(@NonNull MyViewHolder holder, int position) {


        User_android user = userArrayList.get(position);

        holder.name.setText(user.getName());
        holder.pnum.setText(user.getPnum());
        holder.location.setText(user.getLocation());
        holder.reqtype.setText(user.getReqtype());


    }

    @Override
    public int getItemCount() {
        return userArrayList.size();
    }


    public static class MyViewHolder extends RecyclerView.ViewHolder {

        FirebaseFirestore db;
        FirebaseAuth auth;
        String userID;


        TextView name, pnum, reqtype, location;
        ImageView imgdel;
        public MyViewHolder(@NonNull View itemView) {
            super(itemView);
            name = itemView.findViewById(R.id.tvName);
            pnum = itemView.findViewById(R.id.tvPhone);
            location = itemView.findViewById(R.id.tvLocation);
            reqtype = itemView.findViewById(R.id.tvReq);

            imgdel = itemView.findViewById(R.id.img_del);

            db = FirebaseFirestore.getInstance();
            auth = FirebaseAuth.getInstance();

            FirebaseUser currentUser = auth.getCurrentUser();
            userID = currentUser.getUid();



            imgdel.setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    deleteData();
                }
            });
        }

        private void deleteData() {
            db.collection("users").document(userID)
                    .collection("user_logs");
            CollectionReference userLogsRef = db.collection("users").document(userID).collection("user_logs");

            userLogsRef.get()
                    .addOnSuccessListener(new OnSuccessListener<QuerySnapshot>() {
                        @Override
                        public void onSuccess(QuerySnapshot queryDocumentSnapshots) {
                            WriteBatch batch = db.batch();
                            for (QueryDocumentSnapshot document : queryDocumentSnapshots) {
                                batch.delete(document.getReference());
                            }

                            // Commit the batched delete operation
                            batch.commit()
                                    .addOnSuccessListener(new OnSuccessListener<Void>() {
                                        @Override
                                        public void onSuccess(Void aVoid) {
                                            Log.d("DeleteDocuments", "Documents in user_logs subcollection deleted successfully.");
                                            // Perform any UI updates or additional actions after deletion if needed
                                        }
                                    })
                                    .addOnFailureListener(new OnFailureListener() {
                                        @Override
                                        public void onFailure(@NonNull Exception e) {
                                            Log.e("DeleteDocuments", "Error deleting documents: " + e.getMessage());
                                        }
                                    });
                        }
                    })
                    .addOnFailureListener(new OnFailureListener() {
                        @Override
                        public void onFailure(@NonNull Exception e) {
                            Log.e("GetDocuments", "Error getting documents: " + e.getMessage());
                        }
                    });



        }


    }
}